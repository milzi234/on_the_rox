require 'test_setup'

class TestConfig < Test::Unit::TestCase

  def setup
    @conversation = flexmock("webconversation")
    @client = ROX::Client.new()
    @client.webconversation = @conversation
    @client.session = @session = "my-test-session"
    @config = @client.config
  end

  def test_read
    @conversation.should_receive(:get).with("/ajax/config/my/nice/path", :session => @session).once.and_return("{\"data\" : 23}")
    
    value = @config["my/nice/path"]
    assert_equal(23, value)
  end
  
  def test_write
    @conversation.should_receive(:put).with("/ajax/config/my/nice/path", :session => @session, :body => "23").once
    @config["my/nice/path"] = 23
  end
  
  def test_template
    
  end

end