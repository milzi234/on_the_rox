module ROX
  class ConfigTree
    def initialize(client)
      @client = client
    end
    
    def [](path)
      return @client.get_response("/ajax/config/#{path}")["data"]
    end
    
    def []=(path, value)
      @client.put("/ajax/config/#{path}", :body => value.to_json)
    end
  
  end


  class Client
    
    def config
      @config ||= ROX::ConfigTree.new(self)
    end
    
  
  end

end