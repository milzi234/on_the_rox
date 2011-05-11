require 'net/http'
require 'net/https'
require 'open-uri'

module ROX
  class WebConversation
    attr_accessor :cookies
    
    def initialize(uri)
      @cookies = Hash.new
      @uri = URI.parse(uri)
    end
    
    def get(url, params = {})
      req = Net::HTTP::Get.new(url+"?"+query(params))
      res = request(req)
      return res.body
    end
    
    def post(url, params = {})
      stringified_params = Hash.new
      params.each do
        |key, value|
        next if key == :body or key == 'body'
        stringified_params[key.to_s] = value.to_s
      end
      req = Net::HTTP::Post.new(url)
      req.set_form_data(stringified_params)
      req.body = params[:body] || params['body']
      res = request(req)
      return res.body
    end
    
    def put(url, params = {})
      req = Net::HTTP::Put.new(url+"?"+query(params))
      req.body = params[:body] || params['body']
      res = request(req)
      return res.body
    end
    
    def delete(url, params = {})
      req = Net::HTTP::Delete.new(url+"?"+query(params))
      res = request(req)
      return res.body
    end
    
    def remember_cookies(res)
      setCookie = res['Set-Cookie']
      return unless setCookie
      cookies = setCookie.split(/\s*[,;]\s*/)

      cookies.each do
        |cookieDef|
          if (cookieDef =~ /^(JS|open-xchange)/)
            key, value = cookieDef.split(/\=/)
            @cookies[key] = value
          end
        end
      end
    
    def add_cookies(req)
      return if @cookies.empty?
      cookie_string = ""
      @cookies.each do
        |key, value|
        cookie_string << "#{key}=#{value},"
      end
      req["Cookie"] = cookie_string[0...cookie_string.size-1]
    end
    
    def query(params)
      query = ""
      params.each do
        |key, value|
        next if key == :body || key == 'body'
        query += '&'
        query += URI.escape(key.to_s)+"="+URI.escape(value.to_s)
      end
      query = query[1..query.size]
      return query
    end
    
    def request(req)
      add_cookies(req)
      http_session = Net::HTTP.new(@uri.host, @uri.port)
      http_session.use_ssl = @uri.scheme == "https"
      res = http_session.start do
        |http|
        http.request(req)
      end
      remember_cookies(res)
      return res
    end
    
  end
end
