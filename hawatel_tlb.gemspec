# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'hawatel_tlb/version'

Gem::Specification.new do |spec|
  spec.name          = "hawatel_tlb"
  spec.version       = HawatelTlb::VERSION
  spec.authors       = ['Daniel Iwaniuk', 'Przemyslaw Mantaj']
  spec.email         = ['daniel.iwaniuk@hawatel.com', 'przemyslaw.mantaj@hawatel.com']

  spec.summary       = "Ruby gem for failover detection and balancing hosts group"
  spec.description   = %q{Hawatel_tlb is a ruby version load balancing which the purpose is to dynamic return selected address IP/domainame based on specified algorithm}
  spec.homepage      = "http://github.com/hawatel/hawatel_tlb"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.required_ruby_version = '>= 1.9'

  spec.add_development_dependency "bundler", "~> 1.10"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec"
end
