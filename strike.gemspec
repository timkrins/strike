# encoding: utf-8

Gem::Specification.new do |gem|
  gem.authors       = ['Juan Hernández']
  gem.email         = ['juan.hernandez@wuaki.tv']
  gem.description   = %q{Dump a mysql database with sensitive data encrypted}
  gem.summary       = %q{Dump a mysql database with sensitive data encrypted}
  gem.homepage      = 'https://github.com/wuakitv/strike'

  gem.files         = `git ls-files`.split($\)
  gem.executables   = ['strike']
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = 'strike'
  gem.require_paths = ['lib']
  gem.version       = IO.read(File.expand_path('../VERSION', __FILE__))

  gem.add_runtime_dependency 'rake',         '~> 0.9'
  gem.add_runtime_dependency 'my_obfuscate', '~> 0.3.7'
  gem.add_runtime_dependency 'thor',         '~> 0.16.0'
end
