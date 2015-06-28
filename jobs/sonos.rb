require 'net/http'
require 'json'

GET_SONG_URL = ENV["SONOS_URL"]
SCHEDULER.every '2s', first_in: '1s' do |job|
  uri = URI(GET_SONG_URL)
  now_playing = JSON.parse Net::HTTP.get(uri)
  send_event('sonos', now_playing: now_playing)
end