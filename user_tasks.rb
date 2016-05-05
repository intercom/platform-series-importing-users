require './intercom_client'
require './user_actions'
require "csv"

class UserTasks
  include IntercomClient
  include UserActions

  def initialize(your_app_id, your_api_key)
    super(your_app_id, your_api_key)
  end

  def create_user(args)
    #Create a new user with list of values passed on setup
    usr = UserActions.create(args, @intercom)
  end

  def show_attrib(criteria, attrib)
    begin
      #First we check whether this is a standard attribute
      user = UserActions.find_user(criteria, @intercom)
      user.send(attrib.to_sym)
    rescue Intercom::AttributeNotSetError
      begin
        #If we cannot find it is a standard attribute lets check if it is a customer attribute
        user.custom_attributes[attrib]
      end
    end
  end

  def update_customer_attrib(criteria, attrib, value)
    UserActions.update_customer_attrib(criteria, attrib, value, @intercom)
  end

  def delete_user(criteria)
    #delete user using either email, user id or id
    UserActions.delete_user(criteria, @intercom)
  end

  def bulk_delete(*tag)
    case tag.length
      when 0
        emails = @intercom.users.all.map {|user| user.email }
        email_array = emails.collect{|e|{'email'.to_sym => e}}
        #You can use this to automatically delete all your users
        #@intercom.users.submit_bulk_job(delete_items: email_array)
        #But for safety purposes it might be good to just use it to get
        #a list of users which you can pass to a bulk job
        puts(email_array)
      when 1
        emails = Array.new
        @intercom.users.all.map do |user|
          user.tags.each {|val| emails << user.email if val.name.include?(tag[0])}
        end
        email_array = emails.collect{|e|{'email'.to_sym => e}}
        puts(email_array)
        #@intercom.users.submit_bulk_job(delete_items: email_array)
      else
        puts("Only one tag please!")
    end
  end
end

