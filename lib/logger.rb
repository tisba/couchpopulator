module CouchPopulator
  class Logger
    def initialize(logfile='')
      @out = logfile.empty? ? $stdout : File.new(logfile, "a")
    end

    def log(message)
      t = Time.now
      @out << "#{t.strftime("%Y-%m-%d %H:%M:%S")}:#{t.usec} :: #{message} \n"
    end
    
    def <<(message)
      log(message)
    end
  end  
end
