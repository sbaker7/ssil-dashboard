class Keeners
  def initialize
    @list = {}
    @timeout = 30 # mins
    @clear = nil
  end
  def add(user_id, who_keened)
    @list[user_id] = { time: Time.now.to_i, name: who_keened }
    Thread.kill @clear unless @clear.nil?
    @clear = Thread.new do
      sleep @timeout * 60
      # Clear the keeners after 30 mins
      @list = {}
      ping_keen self
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
keeners = Keeners.new
def ping_keen(keeners, play_sound = false)
  Thread.new do
    send_event('keen', { keener: keeners.last, play_sound: play_sound, keen_count: keeners.list.length } )
  end
end
before '/widgets/keen' do
  # Set the auth token
  request.params["auth_token"] = request.params["token"]
  # Make sure request response.body =is in JSON
  request.body.string = request.params.to_json
end
get '/widgets/keen' do
  status 200
  # Register who's keen
  who_keened    = request.params["user_name"]
  user_id       = request.params["user_id"]
  keen_param    = request.params["text"]
  case keen_param
  # No keen parameter -- keening for the first time
  when ''
    if keeners.list.keys.include? user_id
      response.body = "But you're already :caffkeen:?"
    else
      data = keeners.add user_id, who_keened
      if keeners.list.length == 1
        response.body = "You're the first to :caffkeen: up!"
      else
        response.body = ":caffkeen:: " << keeners.to_s
      end
      ping_keen keeners, true
    end
  when 'clear'
    unless keeners.list.keys.include? user_id
      response.body = "But you're not :caffkeen:?"
    else
      keeners.remove user_id
      response.body = "You un-:caffkeen:'ed!"
      ping_keen keeners
    end
  when 'who'
    if keeners.list.length > 0
      response.body = "Here's who's :caffkeen:'ed up:\n" << keeners.to_s
    else
      response.body = "No one is :caffkeen: right now :pensive:"
    end
  when 'help'
    response.body = "How to :caffkeen::\n" <<
                    "`/keen`\n_Make it known that your are :caffkeen:_\n\n" <<
                    "`/keen who`\n_Lists who is keen_\n\n" <<
                    "`/keen clear`\n_Undoes your last keen_\n\n"
  else
    response.body = "Wha?"
  end
end