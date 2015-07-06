require 'net/http'
require 'json'

WHEREABOUTS_URI = ENV["WHEREABOUTS_URI"]

unless WHEREABOUTS_URI
  puts "\e[33mThe whereabouts URI environment variable seems to be missing\e[0m"
else

SCHEDULER.every '10s', first_in: '1s' do |job|
  uri = URI(WHEREABOUTS_URI)
  whereabouts_data = JSON.parse Net::HTTP.get(uri)

  sick = whereabouts_data['staying_home']
  home = whereabouts_data['working_at_home']
  late = whereabouts_data['running_late']
  offsite = whereabouts_data['offsite']
  out = whereabouts_data['out_of_office']

  send_event('whereabouts', sick: sick, home: home, late: late, offsite: offsite, out: out)
end

end