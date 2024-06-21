# frozen_string_literal: true

# Copyright (c) 2024 Yegor Bugayenko
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the 'Software'), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

# A function that turns decorates an object.
#
# Author:: Yegor Bugayenko (yegor256@gmail.com)
# Copyright:: Copyright (c) 2024 Yegor Bugayenko
# License:: MIT
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
      def respond_to?(m, inc = false)
        @origin.respond_to?(m, inc)
      end
      def respond_to_missing?(m, inc = false)
        @origin.respond_to_missing?(m, inc)
      end
    end
    c.class_eval(&)
    r = c.new(origin, attrs)
    return r
  end
  instance_eval("def __get_origin__; @#{origin}; end")
  self.instance_eval do
    def method_missing(*args)
      o = __get_origin__
      o.send(*args) do |*a|
        yield(*a) if block_given?
      end
    end
    def respond_to?(m, inc = false)
      __get_origin__.respond_to?(m, inc)
    end
    def respond_to_missing?(m, inc = false)
      __get_origin__.respond_to_missing?(m, inc)
    end
  end
end
