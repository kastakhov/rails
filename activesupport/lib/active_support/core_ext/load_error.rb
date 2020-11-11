module MissingSourceFileSupport
  module Constants
    REGEXPS = [
      [/^cannot load such file -- (.+)$/i, 1],
      [/^no such file to load -- (.+)$/i, 1],
      [/^Missing \w+ (file\s*)?([^\s]+.rb)$/i, 2],
      [/^Missing API definition file in (.+)$/i, 1]
    ]
  end

  def self.included(klass)
    klass::REGEXPS ||= Constants::REGEXPS
  end

  def is_missing?(path)
    path.gsub(/\.rb$/, '') == self.path.gsub(/\.rb$/, '')
  end
end

if RUBY_VERSION < '2.6.0'

  class MissingSourceFile < LoadError #:nodoc:
    include MissingSourceFileSupport

    attr_reader :path
    def initialize(message, path)
      super(message)
      @path = path
    end

    def self.from_message(message)
      REGEXPS.each do |regexp, capture|
        match = regexp.match(message)
        return MissingSourceFile.new(message, match[capture]) unless match.nil?
      end
      nil
    end
  end

  module ActiveSupport #:nodoc:
    module CoreExtensions #:nodoc:
      module LoadErrorExtensions #:nodoc:
        module LoadErrorClassMethods #:nodoc:
          def new(*args)
            (self == LoadError && MissingSourceFile.from_message(args.first)) || super
          end
        end
        ::LoadError.extend(LoadErrorClassMethods)
      end
    end
  end

else

  class LoadError
    include MissingSourceFileSupport

    unless method_defined?(:path)
      # Returns the path which was unable to be loaded.
      def path
        @path ||= begin
          REGEXPS.find do |regex|
            message =~ regex
          end
          Regexp.last_match(1)
        end
      end
    end
  end

  MissingSourceFile = LoadError

end
