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

def sample_data_app(app_id, api_key, users_num, leads=false, bulk=true)
  #we get strings from cmd line so set values to boolean
  leads = leads.split('=')[1]=="false" ? false : true
  bulk = bulk.split('=')[1]=="false" ? false : true

  #Initialize Intercom with your credentials
  IntercomClient.new(app_id, api_key)
  #Instantiate your user class
  usr = UserTasks.new
  lead = LeadTasks.new
  generator = Namey::Generator.new
  intercom = Intercom::Client.new(app_id: app_id, api_key: api_key)

  #For consistency lets create some fixed companies
  #that will allow us to reuse them and add more employees to each
  #and also to keep the company data the same over time
  company_names = ["Instacorp","Duolux","Zencity",
                   "Virtucon","Lidax","Nugreen",
                   "Stantam","Techitrans",
                   "10 Cities", "Supertouch", "Calmblue",
                   "Dotsense Marketing", "Jump City Green",
                   "Techquake", "Forbin Jensen", "Benno",
                   "Usense", "TwentyOneThings", "HooBoo",
                   "CraveIt", "DemApples", "YoSoy!",
                   "Stronglink SEO"]
  gender_list = ["male", "female"]
  ip_addresses = ["136.0.16.217","85.90.227.224","79.125.105.1",
                  "177.9.63.135","180.216.82.251","124.170.22.91",
                  "128.122.253.1","85.214.132.117","184.154.83.119",
                  "194.32.31.1","106.51.30.0","219.93.13.232"]
  non_company_emails = ["bestmail.com", "examplemail.io", "supermail.net",
                        "genericmail.io", "fantasticmail.net", "iconicemail.com"]
  all_users = []
  now = Time.now.to_i
  eighty_days_ago = now - 80 * 60 * 60 * 24
  two_months_ago = now - 60 * 60 * 60 * 24
  one_month_ago = now - 30 * 60 * 60 * 24
  five_days_ago = now - 5 * 60 * 60 * 24
  a_day_ago = now - 60 * 60 * 24
  two_hours_ago = now - 2 * 60 * 60
  an_hour_ago = now - 60 * 60

  #Create users and store them in array
  (users_num.to_i).times{
    user_data = {}
    #Lets pick a gender
    gender = gender_list.sample
    #30% of time we do not want user to have company
    has_company = Faker::Boolean.boolean(0.9)
    company_name = company_names.sample
    email_domain = SampleCompanies::EMAILS[company_name]

    #Check that it is a user (leads have no companies associated with them)
    if not leads and has_company
      #Add some random company data
      companies = SampleCompanies::COMPANIES[company_name]
      user_data[:companies] = [companies]
    end

    #Add details like name and email
    #Get US Census data for valid names
    users_name = generator.send(gender, :common)
    if not leads
      user_data[:name] = users_name
    end

    if not leads
      #Set email to company email if they have one
      if has_company
        user_data[:email] = Faker::Internet.user_name(users_name) + "@" + email_domain
      else
        user_data[:email] = Faker::Internet.user_name(users_name) + "@" + non_company_emails.sample
      end
    else
      #If it is a lead than we need to create some with no emails
      if Faker::Boolean.boolean(0.3)
        user_data[:email] = Faker::Internet.user_name(users_name) + "@" + non_company_emails.sample
      end
    end
    if not leads
      user_data[:user_id] = Faker::Number.number(5)
    end

    #Add some data for time
    if not leads
      user_data[:signed_up_at] = rand(eighty_days_ago..two_months_ago)
    end
    #user_data[:created_at] = rand(two_months_ago..one_month_ago)
    user_data[:last_request_at] = rand(two_hours_ago..an_hour_ago)
    #30% of the time we will set it to now time
    user_data[:update_last_request_at] = Faker::Boolean.boolean(0.3)

    #Create location via last seen ip
    #user_data[:last_seen_ip] = Faker::Internet.public_ip_v4_address
    user_data[:last_seen_ip] = ip_addresses.sample

    #get some sample avatars to use
    if not leads
      uri = URI.parse("http://api.randomuser.me/?gender=" + gender + "&inc=picture")
      response = Net::HTTP.get_response(uri)
      avatar_url = JSON.parse(response.body)['results'][0]['picture']['large']
      avatar = {:image_url => avatar_url}
      user_data[:avatar] = avatar
    end
    
    #Add some data for Browser info
    user_agent = UserAgentRandomizer::UserAgent.fetch
    user_data[:last_seen_user_agent] = user_agent.string


    #Enable setting so it count as a web sessions
    user_data[:new_session] = true

    #Add some custom fields
    custom_attribs = {
        :Projects => Faker::Number.between(0, 20),
        :Reports => Faker::Number.between(1, 20),
        :Apps => Faker::Number.between(0, 5),
        :Teammates => Faker::Number.between(0, 50),
        :PAID => Faker::Boolean.boolean(0.7),
        :Team_Projects => Faker::Number.between(0, 10),
        :Cancelled_Plan => Faker::Boolean.boolean(0.3),
    }
    user_data[:custom_attributes] = custom_attribs

    #Put it all in an array so we can bulk create it
    all_users << user_data
    #if it is leads there are no bulk jobs
    if leads
      lead.create_lead(user_data)
    end
    if not leads and not bulk
      #Sometimes might want to create single users instead of bulk jobs
      usr.create_user(user_data)
    end
  }
  if not leads and bulk
    intercom.users.submit_bulk_job(create_items: all_users)
  end
  puts all_users

end

sample_data_app(ARGV[0], ARGV[1], ARGV[2], ARGV[3], ARGV[4])