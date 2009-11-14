module Executors
  class Standard
    def initialize(opts={})
      opts = opts.merge(troll_options)

      @docs_per_chunk = opts[:docs]
      @concurrent_inserts = opts[:concurrent_inserts]
      @rounds = opts[:rounds]
    end

    def troll_options
      help = StringIO.new

      opts = Trollop.options do
        version "StandardExecutor v1.0 (c) Sebastian Cohnen, 2009"
        banner <<-BANNER
        This is the StandardExecutor
        BANNER
        opt :docs, "Number of docs per chunk", :default => 2000
        opt :concurrent_inserts, "Number of concurrent inserts", :default => 5
        opt :rounds, "Number of rounds", :default => 2
        opt :preflight, "Generate the docs, but don't write to couch. Use with ", :default => false
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

    def execute(options)
      generator = options[:generator]
      log = options[:logger]

      log << "CouchPopulator's default execution engine has been started."
      log << "Using #{generator.to_s} for generating the documents."

      total_docs = @docs_per_chunk * @concurrent_inserts * @rounds
      log << "Going to insert #{total_docs} generated docs into #{options[:couch_url]}"
      log << "Using #{@rounds} rounds of #{@concurrent_inserts} concurrent inserts with #{@docs_per_chunk} docs each"

      start_time = Time.now

      @rounds.times do |round|
        log << "Starting with round #{round + 1}"
        @concurrent_inserts.times do
          fork do
            # generate payload for bulk_doc
            payload = ({"docs" => generator::generate(@docs_per_chunk)}).to_json

            unless options[:preflight]
              result = CurlAdapter::Invoker.new(options[:couch_url]).post(payload)
            else
              log << "Generated chunk..."
              log << payload
            end
          end
        end
      end
      end_time = Time.now
      duration = end_time - start_time
      
      log << "Execution time: #{duration}s, inserted #{total_docs} (#{total_docs / duration})"
    end


  end
end
