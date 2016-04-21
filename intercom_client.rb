require 'intercom'

class IntercomClient
  #First lets setup the client with your App ID and App Key
  def initialize(your_app_id, your_api_key)
    @@intercom = Intercom::Client.new(app_id: your_app_id, api_key: your_api_key)
  end
end

