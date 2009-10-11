require 'rubygems'
require File.dirname(__FILE__)+'/../lib/rox'
require 'json'

ROX::Client.new(:host => "localhost").login("username", "password") do
  |client|
  response = client.in_module(:apps) do 
    install(:app => "com.openexchange.apps.googlemail")
  end
  puts response
end