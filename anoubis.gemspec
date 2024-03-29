$:.push File.expand_path("lib", __dir__)

# Maintain your gem's version:
require "anoubis/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "anoubis"
  s.version     = Anoubis::VERSION
  s.authors     = ["Andrey Ryabov"]
  s.email       = ["andrey.ryabov@ra-company.kz"]
  s.homepage    = "https://github.com/RA-Company/"
  s.summary     = "Anoubis API Backend System"
  s.description = "Backend API system for simplify creation administration pages and work with databases."
  s.license     = "MIT"
  s.required_ruby_version = '>= 2.7.1'

  s.metadata["homepage_uri"] = s.homepage
  s.metadata["source_code_uri"] = "https://github.com/RA-Company/" + s.name
  s.metadata["changelog_uri"] = "https://github.com/RA-Company/" + s.name + "/blob/main/CHANGELOG.md"
  s.metadata["documentation_uri"] = "https://www.rubydoc.info/gems/" + s.name + "/" + s.version.to_s

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  s.test_files = Dir["spec/**/*"]

  s.add_dependency "rails", ">= 7.0.0"
  s.add_dependency "redis", ">= 4.5.1"
  s.add_dependency "bcrypt", ">= 3.1.16"
  s.add_dependency "rest-client", ">= 2.1.0"
  s.add_dependency "gelf", ">= 3.1.0"

  s.add_development_dependency "rake", ">= 0.13"
  s.add_development_dependency "rspec", ">= 3.10.0"
  s.add_development_dependency "factory_bot_rails", ">= 6.2.0"
end
