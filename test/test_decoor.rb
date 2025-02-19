# frozen_string_literal: true

# SPDX-FileCopyrightText: Copyright (c) 2024-2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT

require 'minitest/autorun'
require_relative '../lib/decoor'

# Decoor main module test.
# Author:: Yegor Bugayenko (yegor256@gmail.com)
# Copyright:: Copyright (c) 2024-2025 Yegor Bugayenko
# License:: MIT
class TestDecoor < Minitest::Test
  def test_object_decoration
    cy = Class.new do
      def booo
        yield 55
      end

      def zero
        0
      end
    end
    x = decoor(cy.new, bar: 42) do
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

  def test_class_decoration
    cy = Class.new do
      def booo
        yield 44
      end

      def to_s
        'yes'
      end
    end
    cz = Class.new do
      decoor(:origin)

      def initialize(origin, bar: nil)
        @origin = origin
        @bar = bar
      end

      def foo
        @bar
      end
    end
    z = cz.new(cy.new, bar: 42)
    assert_equal(42, z.foo)
    assert_equal(45, z.booo { |v| v + 1 })
    assert(z.to_s != 'yes')
  end
end
