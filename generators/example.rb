module Generators
  class Example
    class << self
      def generate(count)
        docs = []
        count.times do
          docs << {
            "title"       => "Example",
            "created_at"  => Time.now - (rand(7) * 60*60*24)
          }
        end
        docs
      end
    end
  end
end