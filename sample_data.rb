require 'csv'
require './user_tasks'
require './tag_tasks'
require './event_tasks'
require './conversation_tasks'

def sample_data(csv_file, app_id, api_key)
  #Initialize Intercom with your credentials
  IntercomClient.new(app_id, api_key)
  #Instantiate your user class
  usr = UserTasks.new
  tag = TagTasks.new
  event = EventTasks.new
  convo = ConversationTasks.new

  #List of user attribtues
  user_attributes = ["email","name","user_id","id","signed_up_at",
                     "last_seen_ip","last_seen_user_agent",
                     "companies","last_request_at"]

  #List of Philosophy related events
  philosophy_events = ["gave-lecture", "thought-deeply", "reviewed-book",
                       "published-book", "published-paper", "questioned-reality",
                       "contemplated-meaning", "tutored-students", "graded-essays"]

  #List of admin responses
  admin_responses = ["hmm", "really?", "not sure", "interesting",
                     "thats deep", "Never thought about that", "chances are slim",
                      "do you like gifs?", "I dont know that much philosophy",
                      "whats the job market like for philosophers?"]

  #List of user hellos
  hello = ["yo", "yo yo", "hey", "Hi", "Hello", "Whats up", "word", "whats the craic", "how you doin"]

  #Iterate through each row and check for user attributes
  CSV.foreach(csv_file, headers:true) do |row|
    begin
      user_data = {}
      for attrib in user_attributes
        if not row[attrib].nil?
          user_data[attrib.to_sym] = row[attrib]
        end
      end
      if not row['custom_attributes'].nil?
        #puts row.inspect
        custom_data = {}
        for line in row['custom_attributes'].split(';')
          vals = line.split(':')
          custom_data[vals[0].to_sym] = vals[1]
        end
        user_data['custom_attributes'] = custom_data
      end
      #Create a user with these attributes
      usr.create_user(user_data)
      #puts user_data
      puts "Creating user:#{row['email']}"

      #Create tags for the users
      if not row['tags'].nil?
        for user_tag in row['tags'].split('::')
          tag.tag_user(row['user_id'], user_tag)
        end
      end

      #Create example events for users
      if not row['events'].nil?
        events = row['events'].split('::')
        3.times {event.submit_event(events.sample , Time.now.to_i, row['user_id'])}
      end

      #Create some sample conversations
      #First get an admin id
      admins = convo.list_admins(show=false)
      if admins.length <= 1
        puts "No Admins Found"
      else
        convo.create_admin_message("Sample Subject",
                                   hello.sample,
                                   admins[0],
                                   row['user_id'])
        user_convos = convo.find_user_convos(row['user_id'])
        if not row['conversations'].nil?
          for msg in row['conversations'].split('::')
            #Check to ensure there is a conversation to reply to
            if user_convos.any?
              convo.user_reply(user_convos[0].id, row['user_id'], :body => msg)
              convo.admin_reply(user_convos[0].id, admins[0], :body => admin_responses.sample)
            end
          end
        end
      end
      rescue NoMethodError, Intercom::BadRequestError => e
        puts "ERROR Creating Users #{e.message}"
      end
  end
end

sample_data(ARGV[0], ARGV[1], ARGV[2])

