lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require File.expand_path('../lib/version', __FILE__)

Gem::Specification.new do |spec|
  spec.name          = 'database-exporter'
  spec.version       = Version::VERSION
  spec.authors       = ['Contentful GmbH (Andreas Tiefenthaler)']
  spec.email         = ['rubygems@contentful.com']
  spec.description   = 'Database exporter that prepares content to be imported'
  spec.summary       = 'Exporter for SQL based databases'
  spec.homepage      = 'https://github.com/contentful/database-exporter.rb'
  spec.license       = 'MIT'
  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables    << 'database-exporter'
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_dependency 'http', '~> 0.6'
  spec.add_dependency 'multi_json', '~> 1'
  spec.add_dependency 'sequel','~> 4.15'
  spec.add_dependency 'mysql2','~> 0.3'
  spec.add_dependency 'activesupport','~> 4.1'
  spec.add_dependency 'pg', '~> 0.17.0'
  spec.add_dependency 'escort','~> 0.4.0'
  spec.add_dependency 'i18n', '~> 0.6'
  spec.add_dependency 'sqlite3', '~> 1.3.10'

  spec.add_development_dependency 'rspec', '~> 3'
  spec.add_development_dependency 'rspec-its', '~> 1.1.0'
  spec.add_development_dependency 'bundler', '~> 1.6'
  spec.add_development_dependency 'rake'
end
