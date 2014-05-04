# -*- encoding: utf-8 -*-

require File.expand_path('../lib/paraphrase/version', __FILE__)

Gem::Specification.new do |gem|
  gem.name          = "paraphrase"
  gem.version       = Paraphrase::VERSION
  gem.summary       = %q{Map query params to model scopes}
  gem.description   = %q{
                        Map query params to model scopes, pairing one or
                        more keys to a scope. Parameters can be required, or
                        whitelisted providing fine tuned control over how
                        scopes are run.
                      }
  gem.license       = "MIT"
  gem.authors       = ["Eduardo Gutierrez"]
  gem.email         = "eduardo@vermonster.com"
  gem.homepage      = "https://github.com/ecbypi/paraphrase"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ['lib']

  gem.required_ruby_version = '>= 1.9.3'

  gem.add_dependency 'activerecord', '>= 3.0', '< 4.2'
  gem.add_dependency 'activesupport', '>= 3.0', '< 4.2'
  gem.add_dependency 'activemodel', '>= 3.0', '< 4.2'

  gem.add_development_dependency 'actionpack', '>= 3.0', '< 4.1'
  gem.add_development_dependency 'bundler', '~> 1.0'
  gem.add_development_dependency 'yard', '~> 0.7'
  gem.add_development_dependency 'rspec', '~> 2.14'
  gem.add_development_dependency 'rake', '~> 0.9.2'
  gem.add_development_dependency 'appraisal', '~> 0.4'
  gem.add_development_dependency 'pry', '~> 0.9'
  gem.add_development_dependency 'codeclimate-test-reporter', '~> 0.3'

  if RUBY_PLATFORM == 'java'
    gem.add_development_dependency 'activerecord-jdbcsqlite3-adapter'
    gem.add_development_dependency 'jdbc-sqlite3'
  else
    gem.add_development_dependency 'sqlite3',  '~> 1.3.6'
    gem.add_development_dependency 'redcarpet', '~> 2.1.1'
  end
end
