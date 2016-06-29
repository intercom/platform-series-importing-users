require './intercom_client'
require './user_tasks'

class LeadTasks < IntercomClient
  def initialize
  end

  def create_lead(args)
    #Allow people to choose which parameters to apply
    @@intercom.contacts.create(args)
  end

  def find_leads(criteria=false)
    #No criteria means search all by default
    if not criteria
      leads = @@intercom.get("/contacts", "")
      if not leads.empty?
        leads['contacts'].each {|contact| puts "EMAIL: #{contact['email']}, NAME: #{contact['name']}", \
                                "USER_ID: #{contact['user_id']}, ID: #{contact['id']}"}
      end
    else
      #Lets use the criteria in different ways to serach contacts
        #Check against email
        lead_list = @@intercom.contacts.find_all(:email => criteria)
        #Check if email returned anything
        if lead_list.any?
          lead_list.each {|lead| puts "EMAIL: #{lead.email}, NAME: #{lead.name}", \
                        "USER_ID: #{lead.user_id}, ID: #{lead.id}"}
        else
          begin
            lead = @@intercom.contacts.find(user_id: criteria)
            return lead
          rescue Intercom::ResourceNotFound
            lead = @@intercom.contacts.find(id: criteria)
            return lead
          end
        end
    end
  end

  def update_lead_attrib(id_or_user_id, attrib=false, value=false)
    #First searchf or the lead and then check if it is custom or standard attribute
    lead = find_leads(id_or_user_id)
    begin
      #This will throw exception if not standard attribute
      lead.send(attrib)
      #If it is standard the simply set it to value
      lead.send("#{attrib}=", value)
    rescue Intercom::AttributeNotSetError
      #If not standard attribute then assume it is a custom attribute
      lead.custom_attributes[attrib] = value
    end
    #Either way we need to save the changed attribute at the end
    @@intercom.contacts.save(lead)
  end

  def convert_leads(lead_id_or_id, lead_email, options={})
    #If no lead is found an exception will be returned
    lead = find_leads(lead_id_or_id)
    #Set some defaults if not set by user
    defaults ={
        :user_id => nil,
        :email => lead_email,
        :name => nil,
    }
    options = defaults.merge(options)
    #Create new Json object to pass through to endpoint
    new_user = {
        contact: {
            :user_id => lead.user_id,
        },
        user: {}
    }
    new_user = new_user.merge(:user => options)

    @@intercom.post("/contacts/convert", new_user)
  end

  def merge_leads(lead_id_or_id, user_criteria)
    lead = find_leads(lead_id_or_id)
    #Check if the user exists
    usr = UserTasks.new
    user = usr.find_user(user_criteria)

    @@intercom.contacts.convert(lead, user)
  end

  def delete_lead(contact_id_or_id)
    lead = find_leads(contact_id_or_id)
    @@intercom.contacts.delete(lead)
  end
end
