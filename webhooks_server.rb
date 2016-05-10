require 'sinatra'
require 'json'

set :bind, '0.0.0.0'

post '/webhook' do
  push = JSON.parse(request.body.read)
  puts "Webhook JSON Data: #{push.inspect}"
end
