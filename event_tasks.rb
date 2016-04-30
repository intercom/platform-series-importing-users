require './intercom_client'
require './user_tasks'

class EventTasks < IntercomClient
  def initialize()
    #Override initialize in IntercomClient
  end

  def submit_event(name, time, criteria, meta_data=false)
    #First check if the user exists,
    #It will throw an exception if it fails to find a user
    user = UserTasks.new()
    usr = user.find_user(criteria)

    #create a hash to pass through to the event API
    event = {:event_name => name,
             :created_at => time,
             :email => usr.email}

    #Check if we need to add metadata to the event
    if meta_data
      event[:metadata] = meta_data
    end

    @@intercom.events.create(event)
  end

  def list_events(criteria)
    #First check if the user exists,
    #It will throw an exception if it fails to find a user
    user = UserTasks.new()
    usr = user.find_user(criteria)
    @@intercom.get("/events", type:"user", user_id:usr.user_id)
  end

  def bulk_create(events, job=false)
    if job
      @@intercom.events.submit_bulk_job(create_items: events, job_id: job)
    else
      @@intercom.events.submit_bulk_job(create_items: events)
    end
  end
end