
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "laksa/version"

Gem::Specification.new do |spec|
  spec.name          = "laksa"
  spec.version       = Laksa::VERSION
  spec.authors       = ["cenyongh"]
  spec.email         = ["cenyongh@gmail.com"]

  spec.summary       = %q{LaksaRuby -- Zilliqa Blockchain  Library}
  spec.description   = %q{LaksaRuby -- Zilliqa Blockchain  Library}
  spec.homepage      = "https://github.com/FireStack-Lab/LaksaRuby"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata["homepage_uri"] = spec.homepage
    spec.metadata["source_code_uri"] = "https://github.com/FireStack-Lab/LaksaRuby"
    spec.metadata["changelog_uri"] = "https://github.com/FireStack-Lab/LaksaRuby"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "minitest", "~> 5.0"
  spec.add_dependency "bitcoin-secp256k1"
  spec.add_dependency "scrypt"
  spec.add_dependency "pbkdf2-ruby"
  spec.add_dependency "jsonrpc-client"
  spec.add_dependency 'google-protobuf'
  spec.add_dependency 'bitcoin-ruby'
end
