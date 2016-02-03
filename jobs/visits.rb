require 'net/http'
require 'json'
require 'pony'

VISITOR_WEBHOOK_URI = "https://hooks.slack.com/services/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"

def send_calendar_event user_id, event_dets
  Thread.new do
    uri = URI.parse VISITOR_WEBHOOK_URI
    msg = { text: "<@" << user_id << "> has created an event: " << event_dets << ". Please wait up to 5 minutes for the event to appear."}.to_json
    response = Net::HTTP.post_form(uri, {"payload" => msg})
  end
  send_event('visitor', {} )
end
before '/widgets/visits' do
  # Set the auth token
  request.params["auth_token"] = request.params["token"]
  # Make sure request response.body =is in JSON
  request.body.string = request.params.to_json
end
get '/widgets/visits' do
  status 200
  name = request.params["user_name"]
  user_id = request.params["user_id"]
  event_dets    = request.params["text"]
  case event_dets
  # No keen parameter -- keening for the first time
  when ''
    puts "A message was received"
    response.body = "You need to include a message. Please specify the event and time."
  else
    puts "I'm about to send an email!"
    response.body = "Sure, I'll make that event for you. Just give me a moment..."
    send_calendar_event user_id, event_dets
    Pony.mail({
      :to => 'trigger@recipe.ifttt.com',
      :via => :smtp,
      :via_options => {
        :address              => 'smtp.gmail.com',
        :port                 => '587',
        :enable_starttls_auto => true,
        :user_name            => 'ssil.events@gmail.com',
        :password             => 'tiphcipwjaggrvko',
        :authentication       => :plain, # :plain, :login, :cram_md5, no auth by default
        :domain               => "localhost.localdomain", # the HELO domain provided by the client to the server
      },
        :subject              => '#visit',
        :body                 => event_dets
    })
  end
end
