require 'minitest/autorun'
require 'json'
require File.expand_path('../../rb/http_util_use_net_http', __FILE__)

class MineApplicationJsonTest < Minitest::Test

  def test_http_util_init_headers
    path = "http://example.org/account/create"
    query = {}
    body = {}
    headers = {content_type: "application/json"}
    uri = HttpUtil.get_uri(path, query)
    req = Net::HTTP::Post.new(uri.request_uri, headers)
    req.each_header do |name, value|
      puts "1. #{name} => #{value}"
    end
  end


  def test_header
    path = "http://example.org/account/create"
    query= {a: '1', b: '2'}
    body = {name: 'body', subs: [id: 1, name: 'c']}
    headers = {"Content-Type" => "application/json"}
    uri = HttpUtil.get_uri(path, query)
    req  = Net::HTTP::Post.new(uri.request_uri, headers)
    req.body = body
    req.each_header do |name, value|
      puts "2. #{name} => #{value}"
    end
    puts req.body
  end


  def test_x_www_form_urlencoded
    path = "http://example.org/account/create"
    query= {a: '1', b: '2'}
    body = {name: 'body', subs: [id: 1, name: 'c']}
    headers = {"Content-Type" => "application/x_www_form_urlencode"}
    uri = HttpUtil.get_uri(path, query)
    req  = Net::HTTP::Post.new(uri.request_uri, headers)
    req.set_form_data(body)
    #req.body = URI.encode_www_form(body)
    req.each_header do |name, value|
      puts "3. #{name} => #{value}"
    end
    puts req.body
  end
end
