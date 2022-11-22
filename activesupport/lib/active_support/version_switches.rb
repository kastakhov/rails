require 'yaml'

module ActiveSupport
  # constant allows people to disable all our Ruby 2 code, if for some reason necessary
  # this is undocumented, because we'd rather it just works for everyone
  if defined?(LTS_MODERN_RUBY)
    def self.modern_ruby?
      LTS_MODERN_RUBY
    end
  elsif RUBY_VERSION >= '2'
    def self.modern_ruby?
      true
    end
  else
    def self.modern_ruby?
      false
    end
  end

  # constant allows people to disable our YAML changes
  if defined?(LTS_YAMLER)
    def self.psych?
      LTS_YAMLER == 'psych'
    end
  # people on 1.9 could potentially have either Syck or Psych
  elsif (defined?(YAML::ENGINE.yamler) ? YAML::ENGINE.yamler != 'syck' : defined?(Psych))
    def self.psych?
      true
    end
  else
    def self.psych?
      false
    end
  end
end

module RailsLts
  module Support
    def self.call_with_keywords(object, method, args, keyword_args)
      # is overwritten for Rails 3+
      object.public_send(method, *(args + [keyword_args]))
    end

    module YAML
      def self.legacy_load(yaml)
        if ::YAML.respond_to?(:unsafe_load)
          ::YAML.unsafe_load(yaml)
        else
          ::YAML.load(yaml)
        end
      end

      def self.legacy_load_file(filename)
        if ::YAML.respond_to?(:unsafe_load_file)
          ::YAML.unsafe_load_file(filename)
        else
          ::YAML.load_file(filename)
        end
      end
    end
  end
end

if RUBY_VERSION >= '3'
  require_relative './version_switches/ruby_3'
end
