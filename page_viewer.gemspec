require File.expand_path("../lib/page_viewer/version", __FILE__)

Gem::Specification.new do |s|
  s.name        = "page_viewer"
  s.version     = PageViewer::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Pete Keen"]
  s.email       = ["pete@petekeen.com"]
  s.homepage    = "http://www.petekeen.com"
  s.summary     = "A Simple Markdown Viewer"
  s.description = "Displays a directory full of markdown files in a web app"

  s.add_dependency "sinatra",     "~> 1.4.2"
  s.add_dependency "docverter",   "~> 1.0.1"
  s.add_dependency "redcarpet",   "~> 2.3.0"
  s.add_dependency "rouge",       "~> 1.4.0"

  s.files        = Dir["{lib}/**/*.rb", "lib/public/*", "lib/views/*", "bin/*", "LICENSE", "*.md", "README.md"]
  s.require_path = 'lib'
end