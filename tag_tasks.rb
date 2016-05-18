require './intercom_client'
require './user_tasks'

class TagTasks < IntercomClient
  def initialize()
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
    @@intercom.tags.untag(name: criteria,  users: [{user_id: tag}])
  end

  def create_tag(tag)
    tag_data = {
        name: tag
    }
    @@intercom.post("/tags", tag_data)
  end
end