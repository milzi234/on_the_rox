require 'test_setup'


#class TestFolderListResponse < Test::Unit::TestCase
  
#end

#class TestFolderResponse < Test::Unit::TestCase

#end


class TestFolder < Test::Unit::TestCase
  def setup
    @conversation = flexmock("webconversation")
    @client = ROX::Client.new()
    @client.webconversation = @conversation
    @client.session = @session = "my-test-session"
    @folders = @client.folders
  end
  
  def test_root
    @conversation.should_receive(:get).with("/ajax/folders", :action => :root, :columns => "1,300", :session => @session).once.and_return("{\"data\" : [[12, \"Folder 1\"],[13, \"Folder 2\"]]}")
    
    @folders.root(:id, :title)
  end
    
end