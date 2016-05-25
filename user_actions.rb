require './intercom_client'
require "csv"

module UserActions
  def UserActions.create(attributes, client)
    user = client.users.create(attributes)
  end

  def UserActions.find_user(criteria, client)
    begin
      #Check for users via the unique ID
      user = client.users.find(:id => criteria)
    rescue Intercom::ResourceNotFound
      begin
        #Check for users via user id if we receive not found error
        user = client.users.find(:user_id=> criteria)
      rescue Intercom::ResourceNotFound
        #Check for users via email address
        user = client.users.find(:email => criteria)
      end
    end
  end

  def UserActions.update_customer_attrib(criteria, attrib, value, client)
    #Create new custom attributes for a user or update existing ones
    #1/ Find the user first
    user = UserActions.find_user(criteria, client)
    # Set/Update the relevant Attribute
    user.custom_attributes[attrib] = value
    # Save the resultant change
    client.users.save(user)
  end

  def UserActions.delete_user(criteria, client)
    #delete user using either email, user id or id
    user = UserActions.find_user(criteria, client)
    deleted_user = client.users.delete(user)
  end

  def UserActions.bulk_create(csv_file, client)
    #Check to make sure the CSV file eixsts
    if File.exist?(csv_file)
      file = File.open(csv_file, "rb")
      body = file.read

      #Need to add to the CSV model to handle empty fields
      CSV::Converters[:blank_to_nil] = lambda do |field|
        field && field.empty? ? nil : field
      end
      csv = CSV.new(body, :headers => true, :header_converters => :symbol, :converters => [:all, :blank_to_nil])
      csv_data = csv.to_a.map {|row| row.to_hash }

      client.users.submit_bulk_job(create_items: csv_data )
    else
      puts("No CSV file found")
    end
  end
end