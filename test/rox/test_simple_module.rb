require 'test_setup'

class TestSimpleModule < Test::Unit::TestCase
  
  def setup
    @client = flexmock("ROX::Client")
    @path = "/ajax/someModule"
    @simpleModule = ROX::SimpleModule.new(@path, @client)
  
  end
  
  def test_force_method
    @client.should_receive(:get_response).with(@path, {:action => "someAction", :someArgument => "someValue"})
    @simpleModule._get(:action => "someAction", :someArgument => "someValue")
    
    @client.should_receive(:put_response).with(@path, {:action => "someAction", :someArgument => "someValue"})
    @simpleModule._put(:action => "someAction", :someArgument => "someValue")
  end
  
  def test_dynamic_method
    @client.should_receive(:get_response).with(@path, {:action => :someAction, :someArgument => "someValue"})
    @simpleModule.someAction(:someArgument => "someValue")
  end
  
  def test_body_in_params_defaults_to_put
      @client.should_receive(:put_response).with(@path, {:action => :someAction, :someArgument => "someValue", :body => [1,2,3].to_json})
      @simpleModule.someAction(:someArgument => "someValue", :body => [1,2,3])
  end
  
  def test_raw_body
    @client.should_receive(:put_response).with(@path, {:action => :someAction, :someArgument => "someValue", :body => [1,2,3].to_json})
    @simpleModule.someAction(:someArgument => "someValue", :body_raw => [1,2,3].to_json)
  end
  

end