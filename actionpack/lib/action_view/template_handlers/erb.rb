require 'active_support/version_switches'

module ActionView
  module TemplateHandlers
    class ERB < TemplateHandler
      include Compilable

      ##
      # :singleton-method:
      # Specify trim mode for the ERB compiler. Defaults to '-'.
      # See ERb documentation for suitable values.
      cattr_accessor :erb_trim_mode
      self.erb_trim_mode = '-'

      def compile(template)
        magic = $1 if template.source =~ /\A(<%#.*coding[:=]\s*(\S+)\s*-?%>)/
        erb = "#{magic}<% __in_erb_template=true %>#{template.source}"

        if erb.respond_to?(:force_encoding)
          erb.force_encoding(template.source.encoding)
        end

        RailsLts::Support::ERB.legacy_new(erb, nil, erb_trim_mode, '@output_buffer').src
      end
    end
  end
end
