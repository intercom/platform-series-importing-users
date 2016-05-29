require './intercom_client'

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
      #Lets use the criteria in differnent ways to serach contacts
        #Check againse email
        lead_list = @@intercom.contacts.find_all(:email => criteria)
        #Check if email returned anything
        if lead_list.any?
          lead_list.each {|lead| puts "EMAIL: #{lead.email}, NAME: #{lead.name}", \
                        "USER_ID: #{lead.user_id}, ID: #{lead.id}"}
        else
          begin
            lead = @@intercom.get("/contacts", user_id: criteria)
            return lead
          rescue Intercom::ResourceNotFound
            lead = @@intercom.get("/contacts/#{criteria}", "")
            return lead
          end
        end
    end
  end

  def update_lead_attrib(user_id, attrib=false, value=false)
    #Create new custom attributes for a lead or update existing ones
    #1/ Find the user first
    lead = find_leads(user_id)
    #Create the Json Object
    update = {
        user_id: lead['user_id'],
        attrib.to_sym => value,
    }
    # Set/Update the relevant Attribute
    @@intercom.post("/contacts/", update)
  end

end
