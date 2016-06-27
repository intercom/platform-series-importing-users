require './user_tasks'
require 'faker'

def web_increment(app_id, api_key, users=[])
  #Initialize Intercom with your credentials
  IntercomClient.new(app_id, api_key)
  #Instantiate your user class
  usr = UserTasks.new
  user_list = users.split(/\s*,\s*/)

  now = Time.now.to_i
  a_day_ago = now - 60 * 60 * 24
  an_hour_ago = now - 60 * 60

  user_list.each do |user_criteria|
    puts user_criteria
    sessions_num = Faker::Number.between(4, 10)
    usr.update_customer_attrib(user_criteria, "new_session", true)
    usr.update_customer_attrib(user_criteria, "last_request_at", rand(a_day_ago..an_hour_ago))

    web_user = usr.find_user(user_criteria)
    (sessions_num.to_i).times{
      usr.create_user(:user_id => web_user.user_id, :update_last_request_at => false,
                      :last_request_at => rand(a_day_ago..an_hour_ago),
                      :new_session => true
      )
      usr.create_user(:user_id => web_user.user_id, :update_last_request_at => true,
                      :last_request_at => rand(a_day_ago..an_hour_ago),
                      :new_session => true
      )
      #usr.update_customer_attrib(user_criteria, "update_last_request_at", false)

      #usr.update_customer_attrib(user_criteria, "update_last_request_at", true)
      #usr.update_customer_attrib(user_criteria, "last_request_at", rand(a_day_ago..an_hour_ago))

      #puts(usr.find_user(user_criteria).last_request_at)
    }
  end

end

web_increment(ARGV[0], ARGV[1], ARGV[2])