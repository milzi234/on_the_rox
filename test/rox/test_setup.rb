LIB_PATH = File.dirname(__FILE__)+"/../../lib"

require 'rubygems'
require 'flexmock/test_unit'
require LIB_PATH+"/rox.rb"


class Test::Unit::TestCase

  def deny(value)
    assert(!value)
  end

end
