# frozen_string_literal: true

# SPDX-FileCopyrightText: Copyright (c) 2024-2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT

require 'English'
require_relative 'lib/decoor'

Gem::Specification.new do |s|
  s.required_rubygems_version = Gem::Requirement.new('>= 0') if s.respond_to? :required_rubygems_version=
  s.required_ruby_version = '>=3.0'
  s.name = 'decoor'
  s.version = '0.0.0'
  s.license = 'MIT'
  s.summary = 'Decoor'
  s.description =
    'A primitive gem that helps you decorate an object or turn an existing
    class into a decorator. The key difference between this gem and a thousand
    other gems that are doing almost the same is that this gem is really
    object-oriented.'
  s.authors = ['Yegor Bugayenko']
  s.email = 'yegor256@gmail.com'
  s.homepage = 'http://github.com/yegor256/decoor.rb'
  s.files = `git ls-files`.split($RS)
  s.rdoc_options = ['--charset=UTF-8']
  s.extra_rdoc_files = ['README.md', 'LICENSE.txt']
  s.metadata['rubygems_mfa_required'] = 'true'
end
