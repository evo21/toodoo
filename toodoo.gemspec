# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'toodoo/version'

Gem::Specification.new do |spec|
  spec.name          = "toodoo"
  spec.version       = Toodoo::VERSION
  spec.authors       = ["Brit Butler"]
  spec.email         = ["redline6561@gmail.com"]
  spec.summary       = %q{A simple terminal todo tracker.}
  spec.description   = %q{Words words words.}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
end
