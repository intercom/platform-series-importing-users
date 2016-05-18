require 'csv'
require './user_tasks'
require './tag_tasks'

def sample_data(csv_file, app_id, api_key)
  #Initialize Intercom with your credentials
  IntercomClient.new(app_id, api_key)
  #Instantiate your user class
  usr = UserTasks.new

  #List of user attribtues
  user_attributes = ["email","name","user_id","id","signed_up_at",
                     "last_seen_ip","last_seen_user_agent",
                     "companies","last_request_at"]
  #Iterate through each row and check for user attributes
  CSV.foreach(csv_file, headers:true) do |row|
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
  end
end

sample_data(ARGV[0], ARGV[1], ARGV[2])

