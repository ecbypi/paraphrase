# -*- encoding: utf-8 -*-

require File.expand_path('../lib/paraphrase/version', __FILE__)

Gem::Specification.new do |gem|
  gem.name          = "paraphrase"
  gem.version       = Paraphrase::VERSION
  gem.summary       = %q{Map param keys to class scopes}
  gem.description   = %q{Map param keys to class scopes}
  gem.license       = "MIT"
  gem.authors       = ["Eduardo Gutierrez"]
  gem.email         = "edd_d@mit.edu"
  gem.homepage      = "https://rubygems.org/gems/paraphrase"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ['lib']

  gem.add_development_dependency 'bundler', '~> 1.0'
  gem.add_development_dependency 'yard', '~> 0.7'
  gem.add_development_dependency 'rspec', '~> 2.10'
  gem.add_development_dependency 'rake', '~> 0.8'
end
