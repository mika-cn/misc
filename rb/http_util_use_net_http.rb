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

  # body: params
  # return a Net::HTTPResponse object
  def self.post(path:, query: {}, body:, headers: {})
     uri = get_uri(path, query)
     req = Net::HTTP::Post.new(uri.request_uri, headers)
     case req.content_type
     when 'application/x-www-form-urlencoded'
       req.body = URI.encode_www_form(body)
     when 'application/json'
       req.body = (body.is_a?(String) ? body : body.to_json)
     when 'multipart/form-data'
       boundary = Boundary.create
       req.content_type = "#{req.content_type}; boundary=#{boundary}"
       req.body = Multipart.new(params: body, boundary: boundary).to_req_body
     end
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

  class Boundary
    require 'securerandom'
    def self.create
      s = SecureRandom.base64(12)
      '----RubyFormBoundary' + s.tr('+/', 'AB')
    end
  end

  class Multipart
    require 'tempfile'
    EOL = "\r\n"
    attr_accessor :params, :boundary
    def initialize(params:, boundary:)
      @params = params
      @boundary = boundary
    end

    def to_req_body
      b = '--' + boundary
      @stream = Tempfile.new("HttpUtil.Stream.#{rand(1000)}")
      @stream.binmode
      @stream.write(b + EOL)
      last_index = params.length - 1
      params.each_with_index do |kv, idx|
        k,v = *kv
        if v.respond_to?(:read) && v.respond_to?(:path)
          create_file_field(@stream, k, v)
        else
          create_regular_field(@stream, k, v)
        end
        @stream.write(EOL + b)
        @stream.write(EOL) if last_index != idx
      end
      @stream.write('--')
      @stream.write(EOL)
      @stream.seek(0)
      c = @stream.read
      @stream.seek(0)
      c
    end

    def create_regular_field(s, k, v)
      s.write("Content-Disposition: form-data; name=\"#{k}\"")
      s.write(EOL)
      s.write(EOL)
      s.write(v)
    end

    def create_file_field(s, k, v)
      begin
        s.write("Content-Disposition: form-data;")
        s.write(" name=\"#{k}\";") unless (k.nil? || k=='')
        s.write(" filename=\"#{v.respond_to?(:original_filename) ? v.original_filename : File.basename(v.path)}\"#{EOL}")
        s.write("Content-Type: #{v.respond_to?(:content_type) ? v.content_type : 'image/jpeg'}#{EOL}")
        s.write(EOL)
        while (data = v.read(8124))
          s.write(data)
        end
      ensure
        v.close if v.respond_to?(:close)
      end
    end
  end

end
