# frozen_string_literal: true

# SPDX-FileCopyrightText: Copyright (c) 2024-2026 Yegor Bugayenko
# SPDX-License-Identifier: MIT

require 'stringio'
require_relative '../lib/decoor'
require_relative 'test__helper'

# Decoor main module test.
# Author:: Yegor Bugayenko (yegor256@gmail.com)
# Copyright:: Copyright (c) 2024-2026 Yegor Bugayenko
# License:: MIT
class TestDecoor < Minitest::Test
  def test_object_decoration
    cy =
      Class.new do
        def booo
          yield(55)
        end
        def zero
          0
        end
      end
    x =
      decoor(cy.new, bar: 42) do
        def foo
          @bar
        end
        def sum
          @origin.zero + 10
        end
      end
    assert_equal(42, x.foo)
    assert_equal(10, x.sum)
    assert_equal(56, x.booo { |v| v + 1 })
  end

  def test_with_named_parameters
    x =
      decoor('') do
        def foo(bar: 42)
          bar + 1
        end
      end
    assert_equal(43, x.foo)
    assert_equal(3, x.foo(bar: 2))
  end

  def test_with_regular_and_named_parameters
    x =
      decoor('') do
        def foo(tmp, bar: 8)
          tmp + bar
        end
      end
    assert_equal(11, x.foo(3))
    assert_equal(12, x.foo(5, bar: 7))
  end

  def test_class_decoration
    z =
      Class.new do
        decoor(:origin)
        def initialize(origin, bar: nil)
          @origin = origin
          @bar = bar
        end
        def foo
          @bar
        end
      end.new(
        Class.new do
          def booo
            yield(44)
          end
          def to_s
            'yes'
          end
        end.new,
        bar: 42
      )
    assert_equal(42, z.foo)
    assert_equal(45, z.booo { |v| v + 1 })
    refute_equal(z.to_s, 'yes')
  end

  def test_object_preserves_block_presence
    origin =
      Class.new do
        def present?
          block_given?
        end
      end.new
    decorated = decoor(origin) { 42 }
    refute_predicate(decorated, :present?)
    refute(decorated.present?(&nil))
    assert(decorated.present? { 42 })
  end

  def test_class_preserves_block_presence
    decorated =
      Class.new do
        decoor(:origin)
        def initialize(origin)
          @origin = origin
        end
      end.new(
        Class.new do
          def present?
            block_given?
          end
        end.new
      )
    refute_predicate(decorated, :present?)
    refute(decorated.present?(&nil))
    assert(decorated.present? { 42 })
  end

  def test_object_returns_enumerator_without_block
    enumerator = decoor([1, 2]) { 42 }.each
    assert_instance_of(Enumerator, enumerator)
    assert_equal([1, 2], enumerator.to_a)
  end

  def test_class_returns_enumerator_without_block
    enumerator =
      Class.new do
        decoor(:origin)
        def initialize(origin)
          @origin = origin
        end
      end.new([1, 2]).each
    assert_instance_of(Enumerator, enumerator)
    assert_equal([1, 2], enumerator.to_a)
  end

  def test_object_preserves_method_visibility
    decorated = decoor(origin) { 42 }
    assert_equal(42, decorated.reveal)
    assert_raises(NoMethodError) { decorated.secret }
    assert_raises(NoMethodError) { decorated.shielded }
    assert_raises(NoMethodError) { decorated.rand }
  end

  def test_class_preserves_method_visibility
    decorated =
      Class.new do
        decoor(:origin)
        def initialize(origin)
          @origin = origin
        end
      end.new(origin)
    assert_equal(42, decorated.reveal)
    assert_raises(NoMethodError) { decorated.secret }
    assert_raises(NoMethodError) { decorated.shielded }
    assert_raises(NoMethodError) { decorated.rand }
  end

  def test_object_responds_to_origin_methods
    decorated = decoor('hello') { 42 }
    assert_respond_to(decorated, :length)
    assert_equal(5, decorated.length)
  end

  def test_object_does_not_respond_to_foreign_methods
    decorated = decoor(Object.new) { 42 }
    refute_respond_to(decorated, :nonexistent)
    refute_respond_to(decorated, :to_ary)
  end

  def test_object_survives_puts_and_flatten
    decorated = decoor(Object.new) { 42 }
    StringIO.new.puts(decorated)
    assert_equal([decorated], [decorated].flatten)
  end

  def test_class_responds_to_origin_methods
    decorated =
      Class.new do
        decoor(:origin)
        def initialize(origin)
          @origin = origin
        end
      end.new('hello')
    assert_respond_to(decorated, :length)
    assert_equal(5, decorated.length)
  end

  def test_class_does_not_respond_to_foreign_methods
    decorated =
      Class.new do
        decoor(:origin)
        def initialize(origin)
          @origin = origin
        end
      end.new('hello')
    refute_respond_to(decorated, :nonexistent)
    refute_respond_to(decorated, :to_ary)
  end

  def test_class_survives_puts_and_flatten
    decorated =
      Class.new do
        decoor(:origin)
        def initialize(origin)
          @origin = origin
        end
      end.new('hello')
    StringIO.new.puts(decorated)
    assert_equal([decorated], [decorated].flatten)
  end

  private

  def origin
    Class.new do
      def reveal
        secret + shielded
      end
      def shielded
        2
      end
      def secret
        40
      end
      protected(:shielded)
      private(:secret)
    end.new
  end
end
