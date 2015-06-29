require 'net/http'
require 'json'

SONOS_URI = ENV["SONOS_URI"]
SCHEDULER.every '2s', first_in: '1s' do |job|
  uri = URI(SONOS_URI)
  now_playing = JSON.parse Net::HTTP.get(uri)
  send_event('sonos', now_playing: now_playing)
end