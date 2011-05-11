module ROX
  
  class SimpleModule
    def initialize(path, client)
      @path = path
      @client = client
    end
    
    def _get(params)
      @client.get_response(@path, params)
    end
    
    def _put(params)
      @client.put_response(@path, params)
    end
    
    def call(action, params)
      _call(action, params)
    end
    
    def _call(action, params)
      params[:action] = action
      if(params[:body])
        params[:body] = params[:body].to_json
        _put(params)
      elsif params[:body_raw]
        params[:body] = params[:body_raw]
        params.delete(:body_raw)
        _put(params)
      else
        _get(params)
      end
    end
    
    def method_missing(meth, *args, &block)
      params = args.first || {}
      _call(meth, params)
    end
    
  end
    
end
