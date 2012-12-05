# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'capybara-repl/version'

Gem::Specification.new do |gem|
  gem.name          = "capybara-repl"
  gem.version       = Capybara::Repl::VERSION
  gem.authors       = ["Alex Skryl"]
  gem.email         = ["rut216@gmail.com"]
  gem.description   = %q{A Capybara REPL environment.}
  gem.summary       = %q{A REPL environment for Capybara and all supported drivers.}
  gem.homepage      = "http://github.com/skryl/capybara-repl"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
end
