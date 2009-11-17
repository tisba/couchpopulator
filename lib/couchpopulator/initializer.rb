module CouchPopulator
  class Initializer
    class << self

      def run
        # process command line options
        command_line_options

        # Only check CouchDB-availibilty when needed
        unless command_line_options[:generate_only]
          Trollop.die :couch, "You need at least to provide the database's name" if command_line_options[:couch].nil?

          # Build the full CouchDB database url
          couch_url = CouchHelper.get_full_couchurl(command_line_options[:couch])

          # Check for availabilty of couchdb
          Trollop.die :couch, "#{couch_url} is not reachable or ressource does not exist" unless CouchHelper.couch_available?(couch_url)

          # create database on demand
          if command_line_options[:create_db]
            # TODO needs to be implemented properly
            # CouchPopulator::CouchHelper.create_db(command_line_options[:couch])
          else
            CouchPopulator::CouchHelper.database_exists? couch_url
          end
        end

        # Get the generator_klass and executor_klass
        generator_klass = begin
          generator(command_line_options[:generator])
        rescue CouchPopulator::GeneratorNotFound
          Trollop.die :generator, "Generator must be set, a valid class-name and respond to generate(n)"
        end

        executor_klass = begin
          executor(executor(ARGV.shift || "standard"))
        rescue CouchPopulator::ExecutorNotFound
          Trollop.die "Executor must be set and a valid class-name"
        end


        # Initialize CouchPopulator
        options = ({:executor_klass => executor_klass, :generator_klass => generator_klass, :logger => CouchPopulator::Logger.new(command_line_options[:logfile])}).merge(command_line_options)
        CouchPopulator::Base.new(options, true).populate
      end

      # Define some command-line options
      def command_line_options
        @command_line_options ||= Trollop.options do
          version "v0.1 (c) Sebastian Cohnen, 2009"
          banner <<-BANNER
This is a simple, yet powerfull tool to import large numbers of on-the-fly generated documents into CouchDB.
It's using concurrency by spawning several curl subprocesses. Documents are generated on-the-fly.

See http://github.com/tisba/couchpopulator for more information.

Usage:
./couchpopulator [OPTIONS] [executor [EXECUTOR-OPTIONS]]

To see, what options for 'executor' are:
./couchpopulator executor -h

OPTIONS:
          BANNER
          opt :couch, "URL of CouchDB Server. You can also provide the name of the target DB only, http://localhost:5984/ will be prepended automatically", :type => String
          opt :create_db, "Create DB if needed.", :default => false
          opt :generator, "Name of the generator-class to use", :default => "Example"
          opt :generate_only, "Generate the docs, but don't write to couch and stdout them instead", :default => false
          opt :logfile, "Redirect info/debug output to specified file instead to stdout", :type => String, :default => ""
          stop_on_unknown
        end
      end

      # Get the requested generator constant or die
      def generator(generator)
        retried = false
        @generator ||= begin
            generator_klass = CouchPopulator::MiscHelper.camelize_and_constantize("couch_populator/generators/#{generator}")
          rescue NameError
            begin
              require File.join(File.dirname(__FILE__), "../../generators/#{generator}.rb")
            rescue LoadError; end # just catch, do nothing
            retry if (retried = !retried)
          ensure
            raise CouchPopulator::GeneratorNotFound if generator_klass.nil?
            generator_klass
        end
      end

      # Get the exexcutor constant (defaults to standard) or die
      def executor(executor)
        retried = false
        @executor ||= begin
            executor_klass = CouchPopulator::MiscHelper.camelize_and_constantize("couch_populator/executors/#{executor}")
          rescue NameError
            begin
              require File.join(File.dirname(__FILE__), "../../executors/#{executor}.rb")
            rescue NameError, LoadError; end # just catch, do nothing
            retry if (retried = !retried)
          ensure
            raise CouchPopulator::ExecutorNotFound if executor_klass.nil?
            executor_klass
          end
      end
    end
  end
end