# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rastrum/version'

Gem::Specification.new do |spec|
  spec.name          = "rastrum"
  spec.version       = Rastrum::VERSION
  spec.authors       = ["Jeffrey C. Witt"]
  spec.email         = ["jeffreycwitt@gmail.com"]

  spec.summary       = %q{A rake like helper for management of TEI transcription files.}
  spec.description   = %q{A rake like helper for management of TEI transcription files.}
  spec.homepage      = "http://github.com/jeffreycwitt/rastrum"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org by setting 'allowed_push_host', or
  # delete this section to allow pushing this gem to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "bin"
  spec.executables   = ["rastrum"]
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.10"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec"

  spec.add_runtime_dependency "thor"
  spec.add_runtime_dependency "nokogiri"
end
