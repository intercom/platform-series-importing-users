require 'intercom'
require './user_tasks'

class ConversationTasks < IntercomClient
  def initialize
    #Leave this empty as an override
  end

  def create_user_message(content, user_id)
    msg_data ={
        body: content,
        from: {
            type:'user',
            user_id: user_id
        }
    }
    @@intercom.post("/messages/", msg_data)
  end

  def create_admin_message(subj, content, admin_id, user_id, msg_type='inapp', templ='plain')
    msg_data ={
        message_type: msg_type,
        subject: subj,
        body: content,
        template: templ,
        from: {
            type:'admin',
            id: admin_id
        },
        to: {
            type: 'user',
            user_id: user_id
        }
    }
    @@intercom.post("/messages/", msg_data)
  end

  def find_all_convos()
    convos = @@intercom.get("/conversations", "")
    convos['conversations'].each {|convo| puts("\nID: #{convo['id']}, \nUSER: #{convo['user']}, \nASSIGNEE: #{convo['assignee']}\n")}
  end

  def find_admin_convos(admin_id, options = {})
    defaults = {
        :type => "admin",
        :open => "false",
        :before => Time.now.to_i
    }
    #Override the deafults if set in options
    options = defaults.merge(options)

    convos = @@intercom.conversations.find_all(:type => options[:type], :id => admin_id,
                                      :open => options[:open], :before => options[:before])
    convos.each{|convo| puts("ID: #{convo.id}, \nUSER: #{convo.user.id}, \nASSIGNEE: #{convo.assignee.id}")}
  end

  def find_user_convos(criteria, options = {})
    #Find user using email, id or user_id
    user = UserTasks.new()
    usr = user.find_user(criteria)

    defaults = {
        :type => 'user',
        :email => usr.email,
        :unread => false
    }
    #Override the deafults if set in options
    options = defaults.merge(options)

    convos = @@intercom.conversations.find_all(:email => options[:email],
                                               :type => options[:type],
                                               :unread => options[:unread])
    convos.each{|convo| puts("ID: #{convo.id}, \nUSER: #{convo.user.id}, \nASSIGNEE: #{convo.assignee.id}")}
  end

  def find_convo(id)
    @@intercom.conversations.find(:id => id)
  end

  def admin_reply(convo_id, admin_id, options={})
    defaults ={
        :type => 'admin',
        :message_type => 'comment',
        :body => "default text"
    }
    #Override the deafults if set in options
    options = defaults.merge(options)

    @@intercom.conversations.reply(:id => convo_id, :type => options[:type],
                                   :admin_id => admin_id,
                                   :message_type => options[:message_type], :body => options[:body])
  end

  def user_reply(convo_id, criteria, options={})
    #Find user using email, id or user_id
    user = UserTasks.new()
    usr = user.find_user(criteria)

    defaults ={
        :type => 'user',
        :message_type => 'comment',
        :body => "default text"
    }
    #Override the deafults if set in options
    options = defaults.merge(options)

    @@intercom.conversations.reply(:id => convo_id, :type => options[:type],
                                   :email => usr.email,
                                   :message_type => options[:message_type], :body => options[:body])
  end

  def list_admins()
    @@intercom.admins.all.each {|admin| puts("ADMIN NAME: #{admin.name},
                                             \nADMIN ID #{admin.id},
                                             \nADMIN EMAIL: #{admin.email}")}
  end

  def convo_action(action, options ={})
    defaults = {
        :admin_id => '0',
        :assignee_id => '1',
        :id => '2'
    }
    options = defaults.merge(options)
    case action
      when "open"
        @@intercom.conversations.open(id: options[:id], admin_id: options[:admin_id])
      when "close"
        @@intercom.conversations.close(id: options[:id], admin_id: options[:admin_id])
      when "assign"
        @@intercom.conversations.assign(id: options[:id], admin_id: options[:admin_id],
                                        assignee_id: options[:assignee_id])
      when "read"
        @@intercom.conversations.mark_read(options[:id])
      else
        puts "Don't recognize this actions, it must be either 'open', 'close', 'assign' or 'read'"
    end
  end
end