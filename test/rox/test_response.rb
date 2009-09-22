require 'test_setup'

class TestResponse < Test::Unit::TestCase
  def test_error
    response = ROX::Response.new({'error' => "An error occurred : %s", 'error_params' => ["Some Error"]})
    assert(response.error?)
    assert_equal("An error occurred : Some Error", response.error)
  end
  
  def test_data
    response = ROX::Response.new({'data' =>  12})
    deny(response.error?)
    assert_equal(12, response.data)
  end

end