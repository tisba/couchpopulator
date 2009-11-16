require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gemspec|
    gemspec.name = "couchpopulator"
    gemspec.summary = "flexible tool for populating CouchDB with generated documents"
    gemspec.description = "flexible tool for populating CouchDB with generated documents"
    gemspec.email = "sebastian.cohnen@gmx.net"
    gemspec.homepage = "http://github.com/tisba/couchpopulator"
    gemspec.authors = ["Sebastian Cohnen"]
    
    gemspec.files = []
    gemspec.files = FileList['lib/**/*.rb'] +
                    FileList['executors/**/*.rb'] +
                    FileList['generators/**/*.rb'] +
                    FileList['bin/*']

    gemspec.has_rdoc = false
    
    gemspec.add_dependency('json', '>=2.0')
    gemspec.add_dependency('trollop', '>=1.15')
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler not available. Install it with: sudo gem install jeweler"
end