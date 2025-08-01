lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "api-pattern/version"

Gem::Specification.new do |spec|
  spec.name          = "api_pattern"
  spec.version       = ApiPattern::VERSION
  spec.authors       = ["trex22"]
  spec.email         = ["contact@jasonchalom.com"]

  spec.summary       = "A client for using the ApiPattern API in Ruby."
  spec.description   = "A client for using the ApiPattern API in Ruby. Built from their api documentation. This is an unofficial project."
  spec.homepage      = "https://github.com/TRex22/ApiPattern"
  spec.license       = "MIT"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.required_ruby_version = ">= 3.0.0"

  spec.add_dependency "httparty", "~> 0.22.0"
  spec.add_dependency "active_attr", "~> 0.15.4"
  spec.add_dependency "nokogiri", "~> 1.16.0"
  spec.add_dependency "csv", "~> 3.3.0"

  # Development dependancies
  spec.add_development_dependency "rake", "~> 13.3.0"
  spec.add_development_dependency "minitest", "~> 5.25.5"
  spec.add_development_dependency "minitest-focus", "~> 1.4.0"
  spec.add_development_dependency "minitest-reporters", "~> 1.7.1"
  spec.add_development_dependency "timecop", "~> 0.9.10"
  spec.add_development_dependency "mocha", "~> 2.4.5"
  spec.add_development_dependency "pry", "~> 0.15.2"
  spec.add_development_dependency "webmock", "~> 3.24.0"
end
