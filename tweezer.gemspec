# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'tweezer/version'

Gem::Specification.new do |spec|
  spec.name          = 'tweezer'
  spec.version       = Tweezer::VERSION
  spec.authors       = ['Griffin Smith']
  spec.email         = ['wildgriffin45@gmail.com']

  spec.summary       = 'Get your gems in their place'

  spec.description   = <<-EOF
    Tweezer is a CLI to add, remove, and edit Gemfile dependencies in an
    automated way
  EOF

  spec.homepage      = 'https://github.com/glittershark/tweezer'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'parser', '~> 2.2'
  spec.add_dependency 'unparser', '~> 0.2'

  spec.add_development_dependency 'bundler', '~> 1.10'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.3'
  spec.add_development_dependency 'rspec-its', '~> 1.2'
  spec.add_development_dependency 'rspec-collection_matchers', '~> 1.1'
  spec.add_development_dependency 'rubocop', '~> 0.34'
  spec.add_development_dependency 'pry', '~> 0.10'
end
