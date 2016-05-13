require 'sinatra'
require 'json'

set :bind, '0.0.0.0'

post '/webhook' do
  body = request.body.read
  push = JSON.parse(body)
  puts "Webhook JSON Data: #{push.inspect}"
  verify_signature(body)
end

def verify_signature(payload_body)
  secret = "HELLO"
  expected = request.env['HTTP_X_HUB_SIGNATURE']
  if expected.nil? || expected.empty? then
    puts "Not signed. Not calculating"
  else
    signature = 'sha1=' + OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha1'), secret, payload_body)
    puts "Expected  : #{expected}"
    puts "Calculated: #{signature}"
    if Rack::Utils.secure_compare(signature, expected) then
      puts "   Match"
    else
      puts "   MISMATCH!!!!!!!"
      return halt 500, "Signatures didn't match!"
    end
  end
end