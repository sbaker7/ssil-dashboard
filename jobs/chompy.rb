require 'net/http'

CHOMPY_WEBHOOK_URI = ENV['CHOMPY_WEBHOOK_URI']

class Chompyers
  def initialize
    @list = {}
    @timeout = 30 # mins
    @clear = nil
  end
  def add(user_id, who_chompyed)
    @list[user_id] = { time: Time.now.to_i, name: who_chompyed, id: user_id }
    Thread.kill @clear unless @clear.nil?
    @clear = Thread.new do
      sleep @timeout * 60
      # Clear the chompyers after 30 mins
      @list = {}
      ping_chompy self
    end
    @list[user_id]
  end
  def to_s
    '<@' << @list.keys.join('>, <@') << '>'
  end
  def remove(user_id)
    @list.delete user_id
  end
  def list
    @list
  end
  def last
    data = @list.sort_by { |uid, data| data[:time] }.last
    unless data.nil?
      return data.last
    else
      return nil
    end
  end
end
chompyers = Chompyers.new
def ping_chompy(chompyers, play_sound = false)
  Thread.new do
    if play_sound
      uri = URI.parse CHOMPY_WEBHOOK_URI
      chompyer = chompyers.last
      msg = { text: "<!channel>: <@" << chompyer[:id] << "> is :chompy:" }.to_json
      response = Net::HTTP.post_form(uri, {"payload" => msg})
    end
    send_event('keen', { chompyer: chompyer, play_sound: play_sound, chompy_count: chompyers.list.length } )
  end
end
before '/widgets/chompy' do
  # Set the auth token
  request.params["auth_token"] = request.params["token"]
  # Make sure request response.body =is in JSON
  request.body.string = request.params.to_json
end
get '/widgets/chompy' do
  status 200
  # Register who's chompy
  who_chompyed    = request.params["user_name"]
  user_id       = request.params["user_id"]
  chompy_param    = request.params["text"]
  case chompy_param
  # No chompy parameter -- chompying for the first time
  when ''
    if chompyers.list.keys.include? user_id
      response.body = "But you're already :chompy:?"
    else
      data = chompyers.add user_id, who_chompyed
      if chompyers.list.length == 1
        response.body = "You're the first to :chompy: up!"
      else
        response.body = ":chompy:: " << chompyers.to_s
      end
      ping_chompy chompyers, true
    end
  when 'clear'
    unless chompyers.list.keys.include? user_id
      response.body = "But you're not :chompy:?"
    else
      chompyers.remove user_id
      response.body = "You un-:chompy:'ed!"
      ping_chompy chompyers
    end
  when 'who'
    if chompyers.list.length > 0
      response.body = "Here's who's :chompy:'ed up:\n" << chompyers.to_s
    else
      response.body = "No one is :chompy: right now :pensive:"
    end
  when 'help'
    response.body = "How to :chompy:\n" <<
                    "`/chompy`\n_Make it known that your are :chompy:_\n\n" <<
                    "`/chompy who`\n_Lists who is chompy_\n\n" <<
                    "`/chompy clear`\n_Undoes your last chompy_\n\n"
  else
    response.body = "Wha?"
  end
end