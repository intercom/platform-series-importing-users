require 'csv'
require './user_tasks'
require 'faker'
require "uri"
require "net/https"
require 'namey'
require "json"
require 'user_agent_randomizer'
require './sample_companies'
require './lead_tasks'

user_list=[]
user_data = {}
intercom = Intercom::Client.new(app_id: 'mzi42gqk', api_key: '223ea74c5dd0a32522d3497e4743ac50f9d20360')
#Initialize Intercom with your credentials
IntercomClient.new('mzi42gqk', '223ea74c5dd0a32522d3497e4743ac50f9d20360')
#Instantiate your user class
usr = UserTasks.new

intercom.users.scroll.each { |user| user_list << user}
#If users array is empty then stop getting next scroll
count=0
user_list.each_slice(100).to_a.each do |users|
  all_users = []
  users.each do |user|
    user_data = {}
    if user.avatar.image_url.nil?
      custom_attribs = {
          :'has avatar' => false
      }
    else
      custom_attribs = {
          :'has avatar' => true
      }
    end
    user_data[:id] = user.id
    user_data[:custom_attributes] = custom_attribs
    #Put it all in an array so we can bulk create it
    all_users << user_data
    count += 1
  end
  intercom.users.submit_bulk_job(create_items: all_users)
  puts(count)
  sleep(3)
end
