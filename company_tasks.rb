require './intercom_client'
require './user_tasks'


class CompanyTasks < IntercomClient
  def initialize()
  end

  def create_companies(comp_name, comp_id, criteria, custom_data=false)
    #First check if the user exists,
    #It will throw an exception if it fails to find a user
    user = UserTasks.new()
    usr = user.find_user(criteria)

    #Create a hash to pass through the company data
    company = {
        :company_id => comp_id,
        :name => comp_name,
    }

    #Check for custom attributes
    if custom_data
      company[:custom_attributes] = custom_data
    end
    puts company

    usr.companies = ([company])
    @@intercom.users.save(usr)

  end

  def find_companies(criteria)
    begin
      #Use exceptions to check other search criteria
      user = @@intercom.companies.find(:id => criteria)
    rescue Intercom::ResourceNotFound
      begin
        #Check for users via company id if we receive not found error
        user = @@intercom.companies.find(:company_id=> criteria)
      rescue Intercom::ResourceNotFound
        #Check for users via company name
        user = @@intercom.companies.find(:name => criteria)
      end
    end
  end

  def list_companies(attrib=false)
    if attrib
      @@intercom.companies.all.each {|company| puts "#{company.name}:#{company.company_id} "\
                                      "- #{attrib}:#{company.custom_attributes[attrib]}"}
    else
      @@intercom.companies.all.map {|company| puts "Company Name: #{company.name}, Company ID: #{company.company_id}" }
    end
  end

  def list_company_users(criteria, attrib=false)
    comp = find_companies(criteria)
    users_list = @@intercom.companies.users(comp.id)
    #Show specific attrib for each user if specified
    if attrib
      users_list.each {|usr| puts usr.send(attrib.to_sym)}
    else
      #Just return the list to alow user perform custom actions
      return(users_list)
    end

  end
end