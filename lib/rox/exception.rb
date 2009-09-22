module ROX

  class OXException < Exception
    def initialize(response)
      @response = response
    end
    
    def to_s
      @response.error
    end
  
  end

end