require 'rake'

Gem::Specification.new do |s|
   s.name = %q{rox}
   s.version = "0.1.0"
   s.date = %q{2011-05-11}
   s.authors = ["Francisco Laguna"]
   s.email = %q{fla@synapps.de}
   s.summary = %q{An Open-Xchange HTTP API client library}
   s.homepage = %q{http://www.ox.io}
   s.description = %q{An Open-Xchange HTTP API client library}
   s.files = FileList['lib/*.rb', 'lib/**/*.rb', 'examples/*.rb', 'README'].to_a
   s.add_dependency('json')
   s.add_dependency('tzinfo')
end