# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'lita/gitter/version'

Gem::Specification.new do |spec|
  spec.name          = "lita-gitter"
  spec.version       = Lita::Gitter::VERSION
  spec.authors       = ["Braiden Vasco"]
  spec.email         = ["braiden-vasco@mailtor.net"]

  spec.summary       = %q{Gitter adapter for the Lita chat bot}
  spec.description   = %q{Gitter adapter for the Lita chat bot.}
  spec.homepage      = "https://github.com/braiden-vasco/lita-gitter"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.9"
  spec.add_development_dependency "rake", "~> 10.0"
end
