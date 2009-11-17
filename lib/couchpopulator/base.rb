module CouchPopulator
  class Base
    def initialize(options)
      @opts = options
      @opts[:couch_url] = CouchHelper.get_full_couchurl options[:couch] unless options[:couch].nil?
    end

    def populate
      @opts[:executor_klass].new(@opts).execute
    end
  end
end