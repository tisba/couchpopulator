module CouchPopulator
  class Base
    def initialize(options, called_from_command_line = false)
      @options = options

      @options[:couch_url] = CouchHelper.get_full_couchurl options[:couch] unless @options[:couch].nil?
      @options.merge!(@options[:executor_klass].command_line_options) if called_from_command_line
    end

    def populate
      @options[:executor_klass].new(@options).execute
    end
  end
end