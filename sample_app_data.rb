require 'csv'
require './user_tasks'
require 'faker'
require "uri"
require "net/https"
require 'namey'
require "json"
require 'user_agent_randomizer'
require './sample_companies'

def sample_data_app(app_id, api_key, users_num)
  #Initialize Intercom with your credentials
  IntercomClient.new(app_id, api_key)
  #Instantiate your user class
  usr = UserTasks.new
  generator = Namey::Generator.new
  intercom = Intercom::Client.new(app_id: app_id, api_key: api_key)

  #For consistency lets create some fixed companies
  #that will allow us to reuse them and add more employees to each
  #and also to keep the company data the same over time
  company_names = ["Instacorp","Duolux","Zencity",
                      "Virtucon","Lidax","Nugreen",
                      "Stantam","Techitrans",
                      "10 Cities", "Supertouch"]
  gender_list = ["male", "female"]

  all_users = []
  now = Time.now.to_i
  five_days_ago = now - 5 * 60 * 60 * 24
  a_day_ago = now - 60 * 60 * 24
  a_minute_ago = now - 60
  an_hour_ago = now - 60 * 60

  #Create users and store them in array
  (users_num.to_i).times{
    user_data = {}
    #Lets pick a gender
    gender = gender_list.sample

    #Add details like name and email
    #user_data[:name] = Faker::Name.name
    #Get US Census data for valid names
    user_data[:name] = generator.send(gender, :common)
    user_data[:email] = Faker::Internet.free_email(user_data[:name])
    user_data[:user_id] = Faker::Number.number(5)

    #Add some data for time
    user_data[:created_at] = rand(five_days_ago..a_day_ago)
    user_data[:last_request_at] = rand(an_hour_ago..now)
    user_data[:signed_up_at] = rand(five_days_ago..a_day_ago)
    #30% of the time we will set it to now time
    user_data[:update_last_request_at] = Faker::Boolean.boolean(0.3)


    #Create location via last seen ip
    user_data[:last_seen_ip] = Faker::Internet.public_ip_v4_address

    #get some sample avatars to use
    uri = URI.parse("http://api.randomuser.me/?gender=" + gender + "&inc=picture")
    response = Net::HTTP.get_response(uri)
    avatar_url = JSON.parse(response.body)['results'][0]['picture']['large']
    avatar = {:image_url => avatar_url}
    user_data[:avatar] = avatar

    #Add some data for Browser info
    user_agent = UserAgentRandomizer::UserAgent.fetch
    user_data[:last_seen_user_agent] = user_agent.string


    #Enable setting so it count as a web sessions
    user_data[:new_session] = true
    #Add some random company data
    companies = SampleCompanies::COMPANIES[company_names.sample]
    user_data[:companies] = [companies]

    #Add some custom fields
    custom_attribs = {
        :Projects => Faker::Number.between(0, 20),
        :Apps => Faker::Number.between(0, 5),
        :Teammates => Faker::Number.between(0, 50),
        :PAID => Faker::Boolean.boolean(0.7),
        :Team_Projects => Faker::Number.between(0, 10),
        :Cancelled_Plan => Faker::Boolean.boolean(0.3),
    }
    user_data[:custom_attributes] = custom_attribs

    #Put it all in an array so we can bulk create it
    all_users << user_data
    #usr.create_user(user_data)

  }
  intercom.users.submit_bulk_job(create_items: all_users)
  puts all_users

end

sample_data_app(ARGV[0], ARGV[1], ARGV[2])