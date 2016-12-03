require 'net/http'
module HttpUtil
  # return a Net::HTTPResponse object
  def self.get(path:, query: {}, headers: {})
     uri = get_uri(path, query)
    http = get_http(uri.host, uri.port)
     req = Net::HTTP::Get.new(uri.request_uri, headers)
     req = (yield req) if block_given?
    http.request(req)
  end

  # body: string
  # return a Net::HTTPResponse object
  def self.post(path:, query: {}, body:, headers: {})
     uri = get_uri(path, query)
    http = get_http(uri.host, uri.port)
     req = Net::HTTP::Post.new(uri.request_uri, headers)
     req.body = body
     req = (yield req) if block_given?
    http.request(req)
  end

  def self.get_http(host, port)
    http = Net::HTTP.new(host, port)
    http.open_timeout = 15
    http.read_timeout = 15
    http
  end

  def self.get_uri(path, query)
    uri = URI(path)
    uri.query = URI.encode_www_form(query)
    uri
  end
end
