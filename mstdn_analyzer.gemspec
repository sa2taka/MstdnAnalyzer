
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "mstdn_analyzer/version"

Gem::Specification.new do |spec|
  spec.name          = "mstdn_analyzer"
  spec.version       = MstdnAnalyzer::VERSION
  spec.authors       = ["sa2taka"]
  spec.email         = ["sa2taka@gmail.com"]

  spec.summary       = %q{Mastodon toot analyzer}
  spec.description   = %q{Mastodon toot analyzer}
  spec.homepage      = "https://github.com/sa2taka"
  spec.license       = "MIT"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency 'mstdn_ivory'
  spec.add_dependency 'ruby-progressbar', '~> 1.10'
  spec.add_dependency 'nokogiri'
  spec.add_dependency 'thor'

  spec.add_development_dependency "bundler", "~> 1.17"
  spec.add_development_dependency "rake", "~> 10.0"
end
