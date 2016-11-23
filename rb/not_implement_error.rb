class NotImplementError < StandardError
  def initialize(context)
    klass_name = (Class == context.class ? context.name : context.class.name)
    super "in class: #{klass_name}"
  end
end

