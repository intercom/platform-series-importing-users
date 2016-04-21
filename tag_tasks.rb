require './intercom_client'
require './user_tasks'

class TagTasks < IntercomClient
  def initialize()
  #  super(app_id, api_key)
  #  user = UserTasks.new(@app_id, @api_key)
  end


  def tag_user(criteria, tag)
    user = UserTasks.new()
    usr = user.find_user(criteria)
    tag = @@intercom.tags.tag(name: tag, users: [{email: usr.email}])
  end

  def tag_users(users, tag)
    users.each {|criteria| tag_user(criteria, tag)}
  end

  def show_tags()
    puts "Tag Name ---- Tag ID"
    @@intercom.tags.all.each {|tag| puts "#{tag.name} - #{tag.id}" }
  end

  def untag(criteria, tag)
    @@intercom.tags.untag(name: 'blue',  users: [{user_id: "42ea2f1b93891f6a99000427"}])
  end
end