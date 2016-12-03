require 'rest-client'
module HttpUtil
  # return RestClient::Response instance
  def self.get(path:, query:{}, headers: {})
    request = RestClient::Request.new({
      method: :get,
      url: to_url(path, query),
      headers: headers
    })
    request = (yield request) if block_given?
    request.execute
  end

  # return RestClient::Response instance
  def self.post(path:, query:{}, body:, headers:{}, &block)
    request = RestClient::Request.new({
      method: :post,
      url: to_url(path, query),
      headers: headers,
      payload: body
    })
    request = (yield request) if block_given?
    request.execute
  end

  private
  def self.to_url(path, query)
    return path if query.empty?
    url = URI.join(path, '?', to_qstr(query)).to_s
  end

  def self.to_qstr(qhash)
    qhash.map{|k,v| "#{k}=#{v}"}.join('&')
  end
end
