module CouchPopulator
  class MiscHelper
    class << self

      def camelize_and_constantize(lower_case_and_underscored_word)
         constantize(camelize(lower_case_and_underscored_word))
      end

      # Borrowed from Rails
      # http://github.com/rails/rails/blob/ea0e41d8fa5a132a2d2771e9785833b7663203ac/activesupport/lib/active_support/inflector.rb#L355
      def camelize(lower_case_and_underscored_word, first_letter_in_uppercase = true)
        if first_letter_in_uppercase
          lower_case_and_underscored_word.to_s.gsub(/\/(.?)/) { "::#{$1.upcase}" }.gsub(/(?:^|_)(.)/) { $1.upcase }
        else
          lower_case_and_underscored_word.first.downcase + camelize(lower_case_and_underscored_word)[1..-1]
        end
      end

      # Ruby 1.9 introduces an inherit argument for Module#const_get and
      # #const_defined? and changes their default behavior.
      if Module.method(:const_get).arity == 1
        # Tries to find a constant with the name specified in the argument string:
        #
        #   "Module".constantize     # => Module
        #   "Test::Unit".constantize # => Test::Unit
        #
        # The name is assumed to be the one of a top-level constant, no matter whether
        # it starts with "::" or not. No lexical context is taken into account:
        #
        #   C = 'outside'
        #   module M
        #     C = 'inside'
        #     C               # => 'inside'
        #     "C".constantize # => 'outside', same as ::C
        #   end
        #
        # NameError is raised when the name is not in CamelCase or the constant is
        # unknown.
        def constantize(camel_cased_word)
          names = camel_cased_word.split('::')
          names.shift if names.empty? || names.first.empty?

          constant = Object
          names.each do |name|
            constant = constant.const_defined?(name) ? constant.const_get(name) : constant.const_missing(name)
          end
          constant
        end
      else
        def constantize(camel_cased_word) #:nodoc:
          names = camel_cased_word.split('::')
          names.shift if names.empty? || names.first.empty?

          constant = Object
          names.each do |name|
            constant = constant.const_get(name, false) || constant.const_missing(name)
          end
          constant
        end
      end
    end
  end
end