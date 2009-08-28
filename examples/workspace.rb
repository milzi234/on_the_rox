require 'rubygems'
require 'lib/oxclient'
require 'json'

conv = OX::WebConversation.new('localhost')
response = conv.get("/ajax/login", :action => :login, :name => 'francisco', :password => 'netline')

session = JSON.parse(response)['session']

response = conv.get('/ajax/subscriptions', :action => :all, :session => session, :columns => "id", :folder => "default0/INBOX")
puts response
puts "="*80
