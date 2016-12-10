require 'net/http'
require 'openssl'

module HttpUtil
  # return a Net::HTTPResponse object
  def self.get(path:, query: {}, headers: {})
     uri = get_uri(path, query)
     req = Net::HTTP::Get.new(uri.request_uri, headers)
     req = (yield req) if block_given?
    http = get_http(uri)
    http.request(req)
  end

  # body: string
  # return a Net::HTTPResponse object
  def self.post(path:, query: {}, body:, headers: {})
     uri = get_uri(path, query)
     req = Net::HTTP::Post.new(uri.request_uri, headers)
     req.body = body
     req = (yield req) if block_given?
    http = get_http(uri)
    http.request(req)
  end

  def self.get_http(uri)
    http = Net::HTTP.new(uri.host, uri.port)
    if 'https' == uri.scheme
      http.verify_mode =  OpenSSL::SSL::VERIFY_NONE
      http.use_ssl = true
    end
    http.open_timeout = 10
    http.read_timeout = 10
    http
  end

  def self.get_uri(path, query)
    uri = URI(path)
    uri.query = URI.encode_www_form(query) if !query.empty?
    uri
  end
end
