require 'rox'

USER = "..."
PASSWORD = "..."
HOST = "https://ox.io"

ROX::Client.new(:host => HOST).login(USER, PASSWORD) do
  |client|
  # ...
  
end