module ActiveSupport
  class OptionMerger #:nodoc:
    instance_methods.each do |method|
      undef_method(method) if method !~ /^(__|instance_eval|class|object_id)/
    end

    def initialize(context, options)
      @context, @options = context, options
    end

    private
      def method_missing(method, *arguments, &block)
        options = nil
        if arguments.last.is_a?(Proc)
          proc = arguments.pop
          arguments << lambda { |*args| @options.deep_merge(proc.call(*args)) }
        elsif arguments.last.respond_to?(:to_hash)
          options = @options.deep_merge(arguments.pop)
        else
          options = @options.dup
        end

        invoke_method(method, arguments, options, &block)
      end
      def invoke_method(method, arguments, options, &block)
        if RUBY_VERSION >= '2.7'
          if options
            @context.__send__(method, *arguments, **options, &block)
          else
            @context.__send__(method, *arguments, &block)
          end
        else
          arguments << options if options
          @context.__send__(method, *arguments, &block)
        end
      end
  end
end
