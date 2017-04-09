
require 'erb'

module ErbRender

  def render_erb
    b = binding
    erb = ::ERB.new(File.new(erb_path).read)
    File.open(out_path, 'w') do |f|
      f.write erb.result(b)
    end
  end

  private

  def erb_path
    throw 'ImplementMe'
  end

  def out_path
    throw 'ImplementMe'
  end

end

class UserRender
  include ErbRender
  attr_accessor :name, :age

  def initialize(name, age)
    @name = name
    @age = age
    create_template_file
  end

  def create_template_file
    # create template file
    File.open(erb_path, 'w') do |f|
      f.write "{name: '<%= @name %>', age: <%= @age%>}"
    end
  end

  def puts_output_file
    puts File.new(out_path).read
  end

  private
  def erb_path
    '/tmp/user.json.erb'
  end

  def out_path
    '/tmp/user.json'
  end
end


r = UserRender.new('mika', 99)
r.render_erb
r.puts_output_file # => {name: 'mika', age: 99}
