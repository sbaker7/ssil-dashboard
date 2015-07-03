require 'dashing'
require 'json'

configure do
  set :auth_token, 'UuTx8umLwoy58itKJrcV0bsi'

  helpers do
    def protected!
     # Put any authentication code you want in here.
     # This method is run before accessing any resource.
    end
  end

  before '/widgets/keen' do
    request.params["auth_token"] = request.params["token"]
    request.body.string = request.params.to_json

    puts request.body.string
  end
end

map Sinatra::Application.assets_prefix do
  run Sinatra::Application.sprockets
end

run Sinatra::Application