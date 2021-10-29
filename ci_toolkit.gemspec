# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name          = "ci_toolkit"
  spec.version       = "1.4.1"
  spec.authors       = ["Gero Keller"]
  spec.email         = ["gero.f.keller@gmail.com"]

  spec.summary       = "Set of CI utilities"
  spec.description   = "Set of tools making it easier to interact between Github PRs and Bitrise CI"
  spec.homepage      = "https://github.com/crvshlab/ci_toolkit"
  spec.license       = "MIT"
  spec.required_ruby_version = ">= 2.6.0"

  spec.metadata["allowed_push_host"] = "https://rubygems.org"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/crvshlab/ci_toolkit"
  spec.metadata["changelog_uri"] = "https://github.com/crvshlab/ci_toolkit/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
    end
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "faraday"
  spec.add_dependency "faraday_middleware"
  spec.add_dependency "jwt"
  spec.add_dependency "octokit"
  spec.add_dependency "openssl"
  spec.add_dependency "time"

  spec.add_development_dependency "rspec", "~> 3.2"
  spec.add_development_dependency "rubocop", "~> 1.7"
  spec.add_development_dependency "rubocop-rake"
  spec.add_development_dependency "rubocop-rspec"
  spec.add_development_dependency "simplecov"
  spec.add_development_dependency "simplecov-json"
end
