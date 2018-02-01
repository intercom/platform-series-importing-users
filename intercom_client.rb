require 'intercom'

class IntercomClient
  #First lets setup the client with your App ID and App Key
  def initialize(token)
    @@intercom = Intercom::Client.new(token: token)
  end
end

