require 'net/http'

CHOMPY_WEBHOOK_URI = ENV['CHOMPY_WEBHOOK_URI']

class Chompiers
  def initialize
    @list = {}
    @timeout = 30 # mins
    @clear = nil
  end
  def add(user_id, who_chompied)
    @list[user_id] = { time: Time.now.to_i, name: who_chompied, id: user_id }
    Thread.kill @clear unless @clear.nil?
    @clear = Thread.new do
      sleep @timeout * 60
      # Clear the chompiers after 30 mins
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
chompiers = Chompiers.new
def ping_chompy(chompiers, play_sound = false)
  Thread.new do
    if play_sound
      uri = URI.parse CHOMPY_WEBHOOK_URI
      chompier = chompiers.last
      msg = { text: "<@" << chompier[:id] << "> is :chompy:" }.to_json
      response = Net::HTTP.post_form(uri, {"payload" => msg})
    end
    send_event('keen', { chompier: chompier, play_sound: play_sound, chompy_count: chompiers.list.length } )
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
  who_chompied    = request.params["user_name"]
  user_id       = request.params["user_id"]
  chompy_param    = request.params["text"]
  case chompy_param
  # No chompy parameter -- chompying for the first time
  when ''
    if chompiers.list.keys.include? user_id
      response.body = "But you're already :chompy:?"
    else
      data = chompiers.add user_id, who_chompied
      if chompiers.list.length == 1
        response.body = "You're the first to :chompy: up!"
      else
        response.body = ":chompy:: " << chompiers.to_s
      end
      ping_chompy chompiers, true
    end
  when 'clear'
    unless chompiers.list.keys.include? user_id
      response.body = "But you're not :chompy:?"
    else
      chompiers.remove user_id
      response.body = "You un-:chompy:'ed!"
      ping_chompy chompiers
    end
  when 'who'
    if chompiers.list.length > 0
      response.body = "Here's who's :chompy:'ed up:\n" << chompiers.to_s
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
