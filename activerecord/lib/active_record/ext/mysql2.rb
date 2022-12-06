if RUBY_VERSION >= '2.4'

  module ActiveRecord
    if defined?(ConnectionAdapters::Mysql2Adapter) && !defined?(ConnectionAdapters::Mysql2Adapter::Fixnum)
      ConnectionAdapters::Mysql2Adapter.const_set(:Fixnum, ::Integer)
    end
  end

end

if RUBY_VERSION >= '2.6' && defined?(Mysql2::Error) && defined?(Mysql2::VERSION) && Gem::Version.new(Mysql2::VERSION) < Gem::Version.new('0.5')

  Mysql2::Error.class_eval <<-RUBY
    prepend(Module.new do
      class StringWithClassicEncode < String
        def encode(encoding_or_options, options = nil)
          if options
            super(encoding_or_options, **options)
          else
            super(**encoding_or_options)
          end
        end
      end

      def sql_state=(state, *args)
        super(StringWithClassicEncode.new(state), *args)
      end

      private

      def clean_message(message, *args)
        super(StringWithClassicEncode.new(message), *args)
      end
    end)
  RUBY

end
