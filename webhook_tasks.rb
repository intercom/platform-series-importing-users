require './intercom_client'

class WebhookTasks < IntercomClient
  def initialize
    #Leave this empty as simple over-ride
  end

  def create_webhook(url, topics, events=false)
    if events
      event_data = {
          service_type: "web",
          topics: ["event.created"],
          url: url,
          metadata: {
          event_names: events
          }
      }
      #Need to POST event metadata for event.created topic
      @@intercom.post("/subscriptions/", event_data)
    else
      #Create a hash to pass through the Webhook data
      webhook = {:url => url,
                 :topics => topics}
      @@intercom.subscriptions.create(webhook)
    end
  end

  def update_webhook(id, url, new_topics, events=false)
    #Create the data you are going to POST
    updates = {
        topics: new_topics,
        url: url,
        }
    if events
      updates[:metadata] = {event_names: events}
    end
    @@intercom.post("/subscriptions/#{id}", updates)
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