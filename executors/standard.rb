module CouchPopulator
  module Executors
    class Standard
      def initialize(opts={})
        @options = self.class.defaults.merge(opts)
      end

      def self.defaults
        @defaults ||= {
          :docs_per_chunk => 1000,
          :concurrent_inserts => 5,
          :rounds => 1
        }
      end

      def self.command_line_options
        help = StringIO.new

        defaults = self.defaults

        opts = Trollop.options do
          version "StandardExecutor v0.1 (c) Sebastian Cohnen, 2009"
          banner <<-BANNER
  This is the StandardExecutor
          BANNER
          opt :docs_per_chunk, "Number of docs per chunk", :default => defaults[:docs_per_chunk]
          opt :concurrent_inserts, "Number of concurrent inserts", :default => defaults[:concurrent_inserts]
          opt :rounds, "Number of rounds", :default => defaults[:rounds]
          opt :help, "Show this message"

          educate(help)
        end

        if opts[:help]
          puts help.rewind.read
          exit
        else
          return opts
        end
      end

      def execute
        rounds = @options[:rounds]
        docs_per_chunk = @options[:docs_per_chunk]
        concurrent_inserts = @options[:concurrent_inserts]
        generator = @options[:generator_klass]

        log = @options[:logger]
        log << "CouchPopulator's default execution engine has been started."
        log << "Using #{generator.to_s} for generating the documents."

        total_docs = docs_per_chunk * concurrent_inserts * rounds
        log << "Going to insert #{total_docs} generated docs into #{@options[:couch_url]}"
        log << "Using #{rounds} rounds of #{concurrent_inserts} concurrent inserts with #{docs_per_chunk} docs each"

        start_time = Time.now

        rounds.times do |round|
          log << "Starting with round #{round + 1}"
          concurrent_inserts.times do
            fork do
              # generate payload for bulk_doc
              payload = JSON.generate({"docs" => generator.generate(docs_per_chunk)})

              unless @options[:generate_only]
                result = CurlAdapter::Invoker.new(@options[:couch_url]).post(payload)
              else
                log << "Generated chunk..."
                puts payload
              end
            end
          end
          concurrent_inserts.times { Process.wait() }
        end

        end_time = Time.now
        duration = end_time - start_time

        log << "Execution time: #{duration}s, #{@options[:generate_only] ? "generated" : "inserted"} #{total_docs}"
      end
    end
  end
end
