$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "workflowable/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "workflowable"
  s.version     = Workflowable::VERSION
  s.authors     = ["Andy Hoernecke"]
  s.email       = ["ahoernecke@netflix.com"]
  s.homepage    = "https://github.com/netflix/workflowable"
  s.summary     = "Add worklow to your Rails application."
  s.description = "Flexible workflow gem."

  s.files = Dir["{app,config,db,lib}/**/*", "LICENSE", "AUTHOR", "Rakefile", "README.md"]
  s.add_dependency "rails", "~> 4.0.4"
  s.add_dependency "jquery-rails"
  s.add_dependency "jbuilder"
  s.add_dependency "nested_form"
  


  s.add_development_dependency "thor"
  s.add_development_dependency "rspec"
  s.add_development_dependency 'rspec-rails'
  s.add_development_dependency 'factory_girl_rails'
  s.add_development_dependency 'database_cleaner'
  s.add_development_dependency "guard-rspec", "~> 4.2.8"
  s.add_development_dependency 'shoulda'  
  s.add_development_dependency 'shoulda-matchers'
  s.add_development_dependency "sqlite3"
  s.add_development_dependency "simplecov"


end
