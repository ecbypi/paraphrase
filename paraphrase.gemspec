# -*- encoding: utf-8 -*-

require File.expand_path('../lib/paraphrase/version', __FILE__)

Gem::Specification.new do |gem|
  gem.name          = "paraphrase"
  gem.version       = Paraphrase::VERSION
  gem.summary       = %q{Map params to model scopes}
  gem.description   = %q{
                        Map query parameters to model scopes, pairing one or
                        more keys to a scope. Parameters can be required, or
                        whitelisted providing fine tuned control over how
                        scopes are run.
                      }
  gem.license       = "MIT"
  gem.authors       = ["Eduardo Gutierrez"]
  gem.email         = "edd_d@mit.edu"
  gem.homepage      = "https://github.com/ecbypi/paraphrase"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ['lib']

  gem.add_dependency 'activerecord', '~> 3.0'
  gem.add_dependency 'activesupport', '~> 3.0'
  gem.add_dependency 'activemodel', '~> 3.0'

  gem.add_development_dependency 'bundler', '~> 1.0'
  gem.add_development_dependency 'yard', '~> 0.7'
  gem.add_development_dependency 'rspec', '~> 2.10'
  gem.add_development_dependency 'redcarpet', '~> 2.1.1'
  gem.add_development_dependency 'rake', '~> 0.9.2'
  gem.add_development_dependency 'sqlite3',  '~> 1.3.6'
  gem.add_development_dependency 'appraisal', '0.4'
end
