require 'csv'
require './user_tasks'
require 'faker'
require "uri"
require "net/https"
require "json"

def sample_data_app(app_id, api_key, users_num)
  #Initialize Intercom with your credentials
  IntercomClient.new(app_id, api_key)
  #Instantiate your user class
  usr = UserTasks.new
  intercom = Intercom::Client.new(app_id: "ja43hiec", api_key: "01e6ba2697aee63c22c4118a1d74845ed643e350")

  all_users = []
  now = Time.now.to_i
  five_days_ago = now - 5 * 60 * 60 * 24
  a_day_ago = now - 60 * 60 * 24
  a_minute_ago = now - 60
  an_hour_ago = now - 60 * 60

  #Create users and store them in array
  (users_num.to_i).times{
    user_data = {}

    #Add details like name and email
    user_data[:name] = Faker::Name.name
    user_data[:email] = Faker::Internet.email

    #Add some data for time
    user_data[:created_at] = rand(five_days_ago..a_day_ago)
    user_data[:last_request_at] = rand(an_hour_ago..now)


    #Create location via last seen ip
    user_data[:last_seen_ip] = Faker::Internet.ip_v4_address

    #get some sample avatars to use
    uri = URI.parse("http://api.randomuser.me/?inc=picture")
    response = Net::HTTP.get_response(uri)
    avatar_url = JSON.parse(response.body)['results'][0]['picture']['large']
    avatar = {:image_url => avatar_url}
    user_data[:avatar] = avatar

    #Add some random company data
    company_name = Faker::Company.name
    company_group = Faker::Company.suffix
    company_desc = Faker::Company.bs
    company_profession = Faker::Company.profession
    company_id = Faker::Number.number(3)
    companies = {
        :name => company_name + "-" + company_group,
        :company_id => company_id,
        #:profession => company_profession,
        #:description => company_desc,
    }
    user_data[:companies] = [companies]

    #Put it all in an array so we can bulk create it
    all_users << user_data
    #usr.create_user(user_data)

  }
  intercom.users.submit_bulk_job(create_items: all_users)
  puts all_users

end

sample_data_app(ARGV[0], ARGV[1], ARGV[2])