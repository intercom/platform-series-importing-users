require './intercom_client'

class SegmentTasks < IntercomClient
  def initialize()
    #Override initialize in IntercomClient
  end

  def get_segment(seg_id)
    #Let's check for the segment first.
    #If it is not there then this will throw an exception
    @@intercom.segments.find(:id => seg_id)
    segs = @@intercom.get("/users", segment_id: seg_id)
    segs['users'].each {|usrs| puts usrs['email']}

    #Alternatively you could iterate through the users list manually
    #@@intercom.users.all.map do |user|
    #  user.segments.each {|val| puts user.email if val.id.include?(seg_id)}
    #end
  end

  def list_segments()
    @@intercom.segments.all.each {|segment| puts "id: #{segment.id} name: #{segment.name}"}
  end
end


