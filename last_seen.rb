require './user_tasks'
require 'faker'

def last_seen(app_id, api_key, users=[])
  #Initialize Intercom with your credentials
  IntercomClient.new(app_id, api_key)
  #Instantiate your user class
  usr = UserTasks.new
  user_list = users.split(/\s*,\s*/)

  now = Time.now.to_i
  a_day_ago = now - 60 * 60 * 24
  an_hour_ago = now - 60 * 60
  three_days_ago = now - 3 * 60 * 60 * 24

  user_list.each do |user_criteria|

    web_user = usr.find_user(user_criteria)
    usr.create_user(:user_id => web_user.user_id, :update_last_request_at => false,
                    :signed_up_at => rand(three_days_ago..a_day_ago),
                    :new_session => true
    )
    puts user_criteria
    sleep 1
  end

end

last_seen(ARGV[0], ARGV[1], ARGV[2])
