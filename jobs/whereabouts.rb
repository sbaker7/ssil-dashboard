require 'net/http'
require 'json'

WHEREABOUTS_URI = ENV["WHEREABOUTS_URI"]
SCHEDULER.every '2s', first_in: '1s' do |job|
  uri = URI(WHEREABOUTS_URI)
  whereabouts_data = JSON.parse Net::HTTP.get(uri)
  sick_people = whereabouts_data['staying_home'].select { |data| data['info'].nil? }.map { | data | data['user'] }
  home_people = whereabouts_data['staying_home'].select { |data| data['info'] == 'working_at_home' }.map { | data | data['user'] }
  late_people = whereabouts_data['running_late'].map { | data | data['user'] }
  send_event('whereabouts', sick: sick_people, late: late_people, home: home_people)
end