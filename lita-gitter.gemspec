# coding: utf-8

Gem::Specification.new do |spec|
  spec.name          = 'lita-gitter'
  spec.version       = '0.1.0'
  spec.authors       = ['Braiden Vasco', 'Gabriel Mazetto']
  spec.email         = ['braiden-vasco@mailtor.net', 'brodock@gmail.com']

  spec.summary       = 'Gitter adapter for the Lita chat bot'
  spec.description   = 'Gitter adapter for the Lita chat bot.'
  spec.homepage      = 'https://github.com/braiden-vasco/lita-gitter'
  spec.license       = 'MIT'

  spec.respond_to?(:metadata) and
    spec.metadata['lita_plugin_type'] = 'adapter'

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end

  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.7'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '>= 3.0.0'
  spec.add_development_dependency 'simplecov'
  spec.add_development_dependency 'coveralls'

  spec.add_runtime_dependency 'lita', '>= 4.4'
  spec.add_runtime_dependency 'em-http-request', '~> 1.1'
  spec.add_runtime_dependency 'multi_json'
end
