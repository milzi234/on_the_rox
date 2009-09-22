require 'test_setup'

class TestClient < Test::Unit::TestCase
  
  def setup
    @conversation = flexmock("Webconversation")
    @client = ROX::Client.new()
    @client.webconversation = @conversation
    @client.session = @session = "my-test-session"
  end
  
  def test_login
    @conversation.should_receive(:get).with("/ajax/login", :action => :login, :name => "francisco", :password => "secret").and_return("{\"session\" : \"3abcdefg\", \"secret\" : \"verySecret\"}").once
    @client.login("francisco", "secret")
    assert_equal("3abcdefg", @client.session)
  end
  
  def test_login_fails
    @conversation.should_receive(:get).with("/ajax/login", :action => :login, :name => "francisco", :password => "secret").and_return("{\"error\" : \"Yuck!\"}").once
    
    assert_raises(ROX::OXException) do
      @client.login("francisco", "secret")
    end
  end
  
  def test_logout
    @conversation.should_receive(:get).with("/ajax/login", :action => :logout, :session => @session).once
    @client.logout()
    assert_nil(@client.session)
  end
  
  def test_logged_in
    assert(@client.logged_in?)
    @client.session = nil
    deny(@client.logged_in?)
  end
  
  def test_login_with_block
    @conversation.should_receive(:get).with("/ajax/login", :action => :login, :name => "francisco", :password => "secret").and_return("{\"session\" : \"3abcdefg\", \"secret\" : \"verySecret\"}").once
    @conversation.should_receive(:get).with("/ajax/login", :action => :logout, :session => "3abcdefg").once
    
    i_ran = false
    
    @client.login("francisco", "secret") do
      |client|
      i_ran = true
      assert_equal(@client, client)
    end
    
    assert(i_ran)
  end
  
  def test_logout_even_with_errors
    @conversation.should_receive(:get).with("/ajax/login", :action => :login, :name => "francisco", :password => "secret").and_return("{\"session\" : \"3abcdefg\", \"secret\" : \"verySecret\"}").once
    @conversation.should_receive(:get).with("/ajax/login", :action => :logout, :session => "3abcdefg").once
    
    assert_raises(RuntimeError) do
      @client.login('francisco', 'secret') do
        raise "Boom"
      end
    end
  end
  
  def test_preserve_blocks_value
    @conversation.should_receive(:get).with("/ajax/login", :action => :login, :name => "francisco", :password => "secret").and_return("{\"session\" : \"3abcdefg\", \"secret\" : \"verySecret\"}").once
    @conversation.should_receive(:get).with("/ajax/login", :action => :logout, :session => "3abcdefg").once
    
    value = @client.login("francisco", "secret") { "Blupp" }
    assert_equal("Blupp", value)
  end
  
  def test_get
    @conversation.should_receive(:get).with("/ajax/some_module", :action => :some_action, :session => @session).once
    @client.get("/ajax/some_module", :action => :some_action)
  end
  
  def test_put
    @conversation.should_receive(:put).with("/ajax/some_module", :action => :some_action, :body => "some_body", :session  => @session).once
    @client.put("/ajax/some_module", :action => :some_action, :body => "some_body")
  end
  
  def test_get_response_no_error
      @conversation.should_receive(:get).with("/ajax/some_module", :action => :some_action, :session => @session).once.and_return("{\"data\" : 12}")
      response = @client.get_response("/ajax/some_module", :action => :some_action)
      assert_equal(12, response.data)
  end
  
  def test_get_response_on_error
    @conversation.should_receive(:get).with("/ajax/some_module", :action => :some_action, :session => @session).once.and_return("{\"error\" : \"Bumm\"}")
    assert_raises(ROX::OXException) do
      @client.get_response("/ajax/some_module", :action => :some_action)
    end
  end
  
    
  
end