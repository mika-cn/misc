module Operator
  class Base

    def initialize(attrs={})
      attrs.each do |name, value|
        self.send("#{name}=", value)
      end
      @raise_mode = false
    end

    def run
      raise "ImplementMe:)"
    end

    def execute
      @executed = true
      run if valid?
    end

    def self.execute!(attrs)
      self.new(attrs).execute!
    end

    def execute!
      @raise_mode = true
      if valid?
        run
      else
        raise errors.join(", ")
      end
    end

    def success?
      check_executed
      errors.empty?
    end

    def validate
      # Implement me if need
    end

    def valid?
      @validation_errors = []
      validate
      @validation_errors.empty?
    end

    ##
    # add validation error
    #
    def add_verr error
      @validation_errors ||= []
      @validation_errors << error
    end

    ##
    # add runtime error
    #
    def add_rerr error
      raise error if @raise_mode
      @runtime_errors ||= []
      @runtime_errors << error
    end

    def errors
      (@validation_errors || []) + (@runtime_errors || [])
    end

    private

    def check_executed
      unless @executed
        raise "Call operator.execute first :)"
      end
    end
  end

end



module Operator
  # 1. extend base
  class Sample < Operator::Base
    # 2. declare attrs
    attr_accessor :attr_a, :attr_b

    # 3. overwrite run
    def run
      if attr_a == 'cool'
        puts "Fine"
      else
        # add runtime error
        add_rerr "Oops!"
      end
    end

    def validate
      # add validation error
      add_verr "attr_b not a integer" unless attr_b.is_a? Integer
    end

  end
end

=begin

  example 1:
  o = Operator::Sample.new(attr_a: 'cool', attr_b: 'not_int')
  o.execute  # do nothing
  o.success? # => false
  o.errors   # => ["attr_b not a integer"]

  example 2:
  o = Operator::Sample.new(attr_a: 'not cool', attr_b: 1)
  o.valid?   # => true
  o.execute
  o.success? # => false
  o.errors   # => ["Oops!"]

=end
