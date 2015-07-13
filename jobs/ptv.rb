require 'ptv_timetable'
require 'geocoder'

DEV_KEY = ENV["PTV_DEVELOPER_KEY"]
SEC_KEY = ENV["PTV_SECURITY_KEY"]

unless (DEV_KEY and SEC_KEY)
  puts "\e[33mThe PTV URI environment variables seem to be missing\e[0m"
else

dbg = false

api = PtvTimetable::API.new(DEV_KEY, SEC_KEY)
GLENFERRIE_STOP_ID = 1080
EXPRESS_LIMIT = 4
GLENFERRIE_COORDS = [-37.8214645, 145.036438]

destination_distance_cache = {}

SCHEDULER.every '1m', first_in: '1s' do |job|
  api.health_check
  departures = api.broad_next_departures(PtvTimetable::TRAIN, GLENFERRIE_STOP_ID).values.first
  departures = departures.map do | departure |
    linedir_id = departure['platform']['direction']['linedir_id']
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
    heading_to   = departure['platform']['direction']['direction_name']
    direction_id = departure['platform']['direction']['direction_id']
    to_city      = direction_id == 0
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
      line_id:              line_id,
      linedir_id:           linedir_id,
      skipped_stations:     skipped_stations,
      destination_distance: destination_distance,
      express:              express,
      heading_to:           heading_to,
      to_city:              to_city,
      direction_id:         direction_id,
      time: {
        timetable:          time_timetable,
        realtime:           time_realtime || nil
      }
    }
  end
  # if two trains leave at the same time, choose the departure that goes the furtherest
  reduced_departures = []
  # so, we will group by
  # - timetable departure time (they leave at the same time)
  # - to_city: they need to be either going up (to city) or down (out from city)
  departures.group_by { | departure | [departure[:time][:timetable], departure[:express], departure[:to_city], departure[:time][:line_id]] }.values.each do | group |
    # if there is only one train leaving at this time then that's okay
    puts ">>>>" if dbg
    if group.length == 1
      puts group if dbg
      # this better not be Camberwell! Camberwell is not a terminus!
      if group.first[:destination_name] == "Camberwell"
        puts "<<<< not resolving as Camberwell is not a terminus!" if dbg
        next
      end
      reduced_departures.push group.first
      puts "<<<< auto resolved #{group.first[:time][:timetable]} to #{group.first[:destination_name]}" if dbg
      next
    end
    # otherwise to resolve the lilydale/belgrave/ringwood issue, we will choose
    # the departure who travel's the furtherest (longest destination distance)
    sorted_by_distance = group.sort_by { |departure| departure[:destination_distance] }
    puts sorted_by_distance if dbg
    furtherest_destination_departure = sorted_by_distance.last
    reduced_departures.push furtherest_destination_departure
    puts "<<<< resolved #{group.first[:time][:timetable]} to #{furtherest_destination_departure[:destination_name]}" if dbg
  end
  reduced_departures = reduced_departures.sort_by { | departure | departure[:time][:time_timetable] }
  send_event('ptv', departures: reduced_departures)
end

end