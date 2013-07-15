$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "bootstrap_rails_helper/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "bootstrap_rails_helper"
  s.version     = BootstrapRailsHelper::VERSION
  s.authors     = ["Hu Hao"]
  s.email       = ["huhao98@gmail.com"]
  s.homepage    = "http://brainet.github.com"
  s.summary     = "Simple rails helper to construct bootstrap components"
  s.description = "Simple rails helper to construct bootstrap components"

  s.files = Dir["{app,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.md"]
  s.test_files = Dir["spec/**/*"]

  s.add_dependency "rails", "~> 3.2.3"
  s.add_development_dependency 'rspec-rails'
end
