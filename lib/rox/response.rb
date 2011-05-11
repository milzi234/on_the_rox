module ROX
  class Response
    def initialize(ox_response)
      @oxresponse = ox_response
    end
    
    def error?
      @oxresponse.include?('error')
    end
    
    def error
      return nil unless error?
      sprintf(@oxresponse['error'], *@oxresponse['error_params'])
    end
    
    def [](key)
      @oxresponse[key.to_s]
    end
    
    def data
      @oxresponse['data']
    end
    
    def to_s
      @oxresponse.inspect
    end
    
  end
end