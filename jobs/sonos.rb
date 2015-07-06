require 'net/http'
require 'json'

SONOS_URI = ENV["SONOS_URI"]

unless SONOS_URI
  puts "\e[33mThe sonos URI environment variable seems to be missing\e[0m"
else

SCHEDULER.every '2s', first_in: '1s' do |job|
    uri = URI(SONOS_URI)
    now_playing = JSON.parse Net::HTTP.get(uri)
    send_event('sonos', now_playing: now_playing)
end

end