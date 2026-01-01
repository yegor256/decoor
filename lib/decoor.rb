# frozen_string_literal: true

# SPDX-FileCopyrightText: Copyright (c) 2024-2026 Yegor Bugayenko
# SPDX-License-Identifier: MIT

# System module, for global functions.
module Kernel
  # Decorates an object by creating a proxy that delegates method calls to the original object.
  #
  # This function creates a decorator pattern implementation that allows transparent delegation
  # to an origin object while optionally adding additional behavior through a block.
  #
  # When called with a block, it creates a new anonymous class that wraps the origin object
  # and evaluates the block in the context of that class, allowing additional methods to be defined.
  #
  # When called without a block from within a class definition, it sets up method_missing
  # to delegate calls to the specified instance variable.
  #
  # @param origin [Object, Symbol] The object to be decorated (when block given) or the name
  #   of an instance variable to delegate to (when no block given)
  # @param attrs [Hash] Optional attributes to be set as instance variables on the decorator
  #   (only used when block is given)
  # @yield Block to be evaluated in the context of the decorator class, allowing additional
  #   methods to be defined
  # @return [Object] The decorated object (when block given) or nil (when no block given)
  #
  # @example Decorating an object with additional behavior
  #   decorated = decoor(original_object, {cache: {}}) do
  #     def cached_result
  #       @cache[:result] ||= @origin.expensive_operation
  #     end
  #   end
  #
  # @example Setting up delegation within a class
  #   class MyClass
  #     def initialize(collaborator)
  #       @collaborator = collaborator
  #     end
  #     decoor :collaborator
  #   end
  #
  # @author Yegor Bugayenko (yegor256@gmail.com)
  # @since 0.1.0
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
end
