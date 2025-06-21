# frozen_string_literal: true

# SPDX-FileCopyrightText: Copyright (c) 2024-2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT

# A function that decorates an object.
#
# Author:: Yegor Bugayenko (yegor256@gmail.com)
# Copyright:: Copyright (c) 2024-2025 Yegor Bugayenko
# License:: MIT
def decoor(origin, attrs = {}, &)
  if block_given?
    c = Class.new do
      def initialize(origin, attrs)
        @origin = origin
        # rubocop:disable Style/HashEachMethods
        # rubocop:disable Lint/UnusedBlockArgument
        attrs.each do |k, v|
          instance_eval("@#{k} = v", __FILE__, __LINE__) # @foo = v
        end
        # rubocop:enable Style/HashEachMethods
        # rubocop:enable Lint/UnusedBlockArgument
      end

      def method_missing(*args)
        @origin.__send__(*args) do |*a|
          yield(*a) if block_given?
        end
      end

      def respond_to?(_mtd, _inc = false)
        true
      end

      def respond_to_missing?(_mtd, _inc = false)
        true
      end
    end
    c.class_eval(&)
    c.new(origin, attrs)
  else
    class_eval("def __get_origin__; @#{origin}; end", __FILE__, __LINE__) # def _get; @name; end
    class_eval do
      def method_missing(*args)
        o = __get_origin__
        o.send(*args) do |*a|
          yield(*a) if block_given?
        end
      end

      def respond_to?(_mtd, _inc = false)
        true
      end

      def respond_to_missing?(_mtd, _inc = false)
        true
      end
    end
  end
end
