module ROX
  
  class Client
    
    attr_accessor :webconversation
    attr_accessor :session
    
    def initialize(options = nil)
      if options
          host = options[:host] 
          raise "Please specify an option 'host'" unless host
          @webconversation = ROX::WebConversation.new(host)
      end
    end
    
    def login(username, password)
      response = @webconversation.get("/ajax/login", :action => :login, :name => username, :password => password)
      response = ROX::Response.new(JSON.parse(response))
      raise OXException.new(response) if response.error?
      @session = response["session"]
      
      if block_given?
        begin
          return yield(self)
        ensure
          logout
        end
      end
      
    end
    
    def logout
      response = @webconversation.get("/ajax/login", :action => :logout, :session => session)
      if(response and response != "")
        response = ROX::Response.new(JSON.parse(response))
        raise OXException.new(response) if response.error?
      end
      @session = nil
    end
    
    def logged_in?
      !@session.nil?
    end
    
    def get(path, parameters = {})
      parameters[:session] ||= @session
      @webconversation.get(path, parameters)
    end
    
    def put(path, parameters = {})
      parameters[:session] ||= @session
      @webconversation.put(path, parameters)
    end
    
    def get_response(path, parameters = {})
      response = ROX::Response.new(JSON.parse(get(path, parameters)))
      raise ROX::OXException.new(response) if response.error?
      return response;
    end
    
    def put_response(path, parameters = {}) 
      response = ROX::Response.new(JSON.parse(put(path, parameters)))
      raise ROX::OXException.new(response) if response.error?
      return response
    end
    
    def in_module(moduleName, &block)
      mod = self.module(moduleName)
      return mod.instance_eval(&block) if block_given?
      return mod
    end
    
    def module(moduleName)
      ROX::SimpleModule.new("/ajax/"+moduleName.to_s, self)
    end
  end
  
end