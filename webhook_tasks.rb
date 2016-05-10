require './intercom_client'

class WebhookTasks < IntercomClient
  def initialize
    #Leave this empty as simple over-ride
  end

  def create_webhook(url, topics)
    #Create a hash to pass through the Webhook data
    webhook = {:url => url,
               :topics => topics}
    @@intercom.subscriptions.create(webhook)
  end

  def list_subscriptions(attrib=false)
    #Check if there is an attribute specified
    if attrib
      #If there is then assume just this attribute is needed
      @@intercom.subscriptions.all.each {|sub| puts "#{sub.send(attrib.to_sym)}"};
    else
      #Print out default of most useful attributes
      @@intercom.subscriptions.all.each {|sub| puts "#{sub.id}, #{sub.url}, #{sub.active}, #{sub.topics}"};
    end
  end

  def get_subscription(id)
    #The ID is the only unique element of the webhook
    @@intercom.subscriptions.find(:id => id)
  end

  def delete_subscriptions(id)
    #Delete single subscription given Subscription ID
    #We dont have any query parameters so 2nd function param is empty string
    @@intercom.delete("/subscriptions/#{id}", "")
  end
end