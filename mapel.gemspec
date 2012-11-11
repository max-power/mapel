# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'mapel/version'

Gem::Specification.new do |gem|
  gem.name          = "mapel"
  gem.version       = Mapel::VERSION
  gem.authors       = ["Aleksander Williams"]
  gem.email         = %q{alekswilliams@earthlink.net}
  gem.description   = %q{Mapel is a dead-simple, chainable image-rendering DSL for ImageMagick.}
  gem.summary       = %q{A dead-simple image-rendering DSL.}
  gem.homepage      = %q{http://github.com/akdubya/mapel}

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
  
  gem.add_development_dependency 'rake'
  gem.add_development_dependency 'turn'
end
