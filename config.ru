require 'dashing'

configure do
  set :auth_token, 'UuTx8umLwoy58itKJrcV0bsi'
end

map Sinatra::Application.assets_prefix do
  run Sinatra::Application.sprockets
end

run Sinatra::Application