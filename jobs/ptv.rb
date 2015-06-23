require 'ptv_timetable'
require 'geocoder'

DEV_KEY = ENV["PTV_DEVELOPER_KEY"] || "1000089"
SEC_KEY = ENV["PTV_SECURITY_KEY"] || "f2faba58-ad71-11e3-8bed-0263a9d0b8a0"

api = PtvTimetable::API.new(DEV_KEY, SEC_KEY)
GLENFERRIE_STOP_ID = 1080
EXPRESS_LIMIT = 4
GLENFERRIE_COORDS = [-37.8214645, 145.036438]

destination_distance_cache = {}

SCHEDULER.every '1m', first_in: '1s' do |job|
  api.health_check
  departures = api.broad_next_departures(PtvTimetable::TRAIN, GLENFERRIE_STOP_ID).values.first
  departures = departures.map do | departure |
    skipped_stations = departure['run']['num_skipped']
    destination_name = departure['run']['destination_name']
    destination_id = departure['run']['destination_id']
    line_id = departure['platform']['direction']['line']['line_id']
    # stop not stored in destination_cache?
    if destination_distance_cache[destination_id].nil?
      # merge in the lat and lon of every stop id on this line
      destination_distance_cache.merge! api.line_stops(PtvTimetable::TRAIN, line_id).map { |stop| [stop["stop_id"], [stop["lat"], stop["lon"]]] }.to_h
    end
    # work out distance from glenferrie
    destination_coords = destination_distance_cache[destination_id]
    destination_distance = Geocoder::Calculations.distance_between GLENFERRIE_COORDS, destination_coords
    # work out if it is express or not
    express =
      if skipped_stations > EXPRESS_LIMIT
        'express'
      elsif skipped_stations < EXPRESS_LIMIT and skipped_stations >= 1
        'limited express'
      elsif skipped_stations == 0
        'stopping all stations'
      end
    # work out heading to
    heading_to = departure['platform']['direction']['direction_name']
    to_city    = departure['platform']['direction']['direction_id'] == 0
    # remove "City" to get terminus station name in city
    heading_to = heading_to.gsub(/City|[()]|^\s|$\s/, '').strip! if to_city
    # get the timetable departing time
    time_timetable = DateTime.parse departure['time_timetable_utc']
    # not yet implemented in PTV API, so will be nil
    # but realtime feature may come soon
    unless departure['time_realtime_utc'].nil?
      time_realtime = DateTime.parse departure['time_realtime_utc']
    end
    {
      destination_name:     destination_name,
      destination_distance: destination_distance,
      express:              express,
      heading_to:           heading_to,
      to_city:              to_city,
      time: {
        timetable:          time_timetable,
        realtime:           time_realtime || nil
      }
    }
  end
  # if two trains leave at the same time, choose the departure that goes the furtherest
  reduced_departures = []
  departures.group_by { | departure | departure[:time][:timetable] }.values.each do | group |
    # if there is only one train leaving at this time then that's okay
    if group.length == 1
      reduced_departures.push group.first
      next
    end
    # TODO: need to check if to city or not to city!!!!
    puts ">>>>> "
    puts group.sort_by { |departure| departure[:destination_distance] }
    last = group.sort_by { |departure| departure[:destination_distance] }.last
    reduced_departures.push last
    puts "<<<< resolved to #{last[:destination_name]}"
  end
  reduced_departures = reduced_departures.sort_by { | departure | departure[:time][:time_timetable] }
  send_event('ptv', departures: reduced_departures)
end