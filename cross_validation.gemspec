# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'cross_validation'

Gem::Specification.new do |gem|
  gem.name          = "cross_validation"
  gem.version       = CrossValidation::VERSION
  gem.authors       = ["Jon-Michael Deldin"]
  gem.email         = ["dev@jmdeldin.com"]
  gem.summary       = %q{Performs k-fold cross-validation on machine learning
                      classifiers.}
  gem.description   = gem.summary
  gem.homepage      = 'https://github.com/jmdeldin/cross_validation'

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
end
