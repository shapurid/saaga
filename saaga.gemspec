# frozen_string_literal: true

require_relative 'lib/saaga/version'

Gem::Specification.new do |spec|
  spec.name = 'saaga'
  spec.version = Saaga::VERSION
  spec.summary = 'A simple saga pattern implementation'
  spec.description = 'A simple saga pattern implementation'
  spec.author = 'Ivan Korney'
  spec.email = 'shapurid@yandex.ru'
  spec.homepage = 'https://rubygems.org/gems/hola'
  spec.license = 'MIT'

  spec.files = Dir['lib/**/*']
  spec.require_paths = ['lib']

  spec.metadata['rubygems_mfa_required'] = 'true'

  spec.required_ruby_version = '>= 3.0.0'

  spec.add_development_dependency 'minitest'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'reek'
  spec.add_development_dependency 'rubocop'
  spec.add_development_dependency 'rubocop-minitest'
  spec.add_development_dependency 'rubocop-performance'
  spec.add_development_dependency 'rubocop-rake'
  spec.add_development_dependency 'solargraph'
  spec.add_development_dependency 'solargraph-reek'
end
