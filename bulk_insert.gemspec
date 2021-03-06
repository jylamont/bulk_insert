# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'bulk_insert/version'

Gem::Specification.new do |spec|
  spec.name          = "bulk_insert"
  spec.version       = BulkInsert::VERSION
  spec.authors       = ["James Lamont"]
  spec.email         = ["james@semblancesystems.com"]
  spec.description   = %q{Quick and dirty mass-insert with ActiveRecord and PostgreSQL.}
  spec.summary       = ""
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "pg"
  spec.add_runtime_dependency "activerecord", "~> 3.2"
end
