def decoor(origin, attrs = {}, &)
  if block_given?
    c = Class.new do
      def initialize(o, attrs)
        @origin = o
        attrs.each { |k, v| instance_eval("@#{k} = v") }
      end
      def method_missing(*args)
        @origin.__send__(*args) do |*a|
          yield(*a) if block_given?
        end
      end
    end
    c.class_eval(&)
    r = c.new(origin, attrs)
    return r
  end
  instance_eval("def __get_origin__; @#{origin}; end")
  self.instance_eval do
    def method_missing(*args)
      o = self.__get_origin__
      o.send(*args) do |*a|
        yield(*a) if block_given?
      end
    end
  end
end

class Y
  def booo
    yield 55
  end
end

x = decoor(Y.new, bar: 42) do
  def foo
    @bar
  end
end

raise unless x.foo == 42
x.booo { |v| raise unless v == 55 }

class Z
  def initialize(origin, bar: nil)
    @origin = origin
    @bar = bar
    decoor(:origin)
  end
  def foo
    @bar
  end
end

z = Z.new(Y.new, bar: 42)
raise unless z.foo == 42
z.booo { |v| raise unless v == 55 }
