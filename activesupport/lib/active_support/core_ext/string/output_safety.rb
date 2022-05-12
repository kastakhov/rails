require 'erb'

class ERB
  module Util
    HTML_ESCAPE = { '&' => '&amp;',  '>' => '&gt;',   '<' => '&lt;', '"' => '&quot;', "'" => '&#39;' }
    JSON_ESCAPE = { '&' => '\u0026', '>' => '\u003E', '<' => '\u003C', "\u2028" => '\u2028', "\u2029" => '\u2029' }
    TAG_NAME_REPLACEMENT_CHAR = "_"

    if defined?(::Encoding::US_ASCII)
      REGEXP = Regexp.new(%([&"'><]), ::Encoding::US_ASCII)
    else
      REGEXP = /[&"'><]/n
    end

    if RUBY_VERSION >= '1.9'
      # Following XML requirements: https://www.w3.org/TR/REC-xml/#NT-Name
      TAG_NAME_START_REGEXP_SET = ":A-Z_a-z\u{C0}-\u{D6}\u{D8}-\u{F6}\u{F8}-\u{2FF}\u{370}-\u{37D}\u{37F}-\u{1FFF}" \
                                  "\u{200C}-\u{200D}\u{2070}-\u{218F}\u{2C00}-\u{2FEF}\u{3001}-\u{D7FF}\u{F900}-\u{FDCF}" \
                                  "\u{FDF0}-\u{FFFD}\u{10000}-\u{EFFFF}"
      TAG_NAME_START_REGEXP = /[^#{TAG_NAME_START_REGEXP_SET}]/u
      TAG_NAME_FOLLOWING_REGEXP = /[^#{TAG_NAME_START_REGEXP_SET}\-.0-9\u{B7}\u{0300}-\u{036F}\u{203F}-\u{2040}]/u

      # https://infra.spec.whatwg.org/#noncharacter
      NONCHARACTER_REGEXP_SET = "\u{FDD0}-\u{FDEF}\u{FFFE FFFF 1FFFE 1FFFF 2FFFE 2FFFF 3FFFE 3FFFF 4FFFE 4FFFF 5FFFE 5FFFF 6FFFE 6FFFF 7FFFE 7FFFF 8FFFE 8FFFF 9FFFE 9FFFF AFFFE AFFFF BFFFE BFFFF CFFFE CFFFF DFFFE DFFFF EFFFE EFFFF FFFFE FFFFF 10FFFE 10FFFF}"
      # https://html.spec.whatwg.org/#syntax-attribute-name
      ATTRIBUTE_NAME_INVALID_CHARS = /[ "'>\/=\p{Control}#{NONCHARACTER_REGEXP_SET}]/u
    else
      # On ruby 1.8.7 we cannot handle unicode chars, so will have to resort to only allowing 7bit ascii
      TAG_NAME_START_REGEXP_SET = ":A-Z_a-z"
      TAG_NAME_START_REGEXP = /[^#{TAG_NAME_START_REGEXP_SET}]/
      TAG_NAME_FOLLOWING_REGEXP = /[^#{TAG_NAME_START_REGEXP_SET}\-.0-9]/

      # https://infra.spec.whatwg.org/#control
      ASCII_CONTROL_CHAR_REGEXP_SET = "\000-\037\177" # Octal
      NON_ASCII_REGEXP_SET = "\200-\377" # Octal
      ATTRIBUTE_NAME_INVALID_CHARS = /[ "'>\/=#{ASCII_CONTROL_CHAR_REGEXP_SET}#{NON_ASCII_REGEXP_SET}]/
    end

    # A utility method for escaping HTML tag characters.
    # This method is also aliased as <tt>h</tt>.
    #
    # In your ERB templates, use this method to escape any unsafe content. For example:
    #   <%=h @person.name %>
    #
    # ==== Example:
    #   puts html_escape("is a > 0 & a < 10?")
    #   # => is a &gt; 0 &amp; a &lt; 10?
    def html_escape(s)
      s = s.to_s
      if s.html_safe?
        s
      else
        s.gsub(REGEXP) { |special| HTML_ESCAPE[special] }.html_safe
      end
    end

    undef :h
    alias h html_escape

    module_function :html_escape
    module_function :h

    # A utility method for escaping HTML entities in JSON strings.
    # This method is also aliased as <tt>j</tt>.
    #
    # In your ERb templates, use this method to escape any HTML entities:
    #   <%=j @person.to_json %>
    #
    # ==== Example:
    #   puts json_escape("is a > 0 & a < 10?")
    #   # => is a \u003E 0 \u0026 a \u003C 10?
    def json_escape(s)
      s.to_s.gsub(/[&"><]|\u2028|\u2029/u) { |special| JSON_ESCAPE[special] }
    end

    alias j json_escape
    module_function :j
    module_function :json_escape

    # A utility method for escaping XML names of tags and names of attributes.
    #
    #   xml_name_escape('1 < 2 & 3')
    #   # => "1___2___3"
    #
    # It follows the requirements of the specification: https://www.w3.org/TR/REC-xml/#NT-Name
    def xml_name_escape(name)
      name = name.to_s
      return "" if name.blank?

      starting_char = name[0, 1].gsub(TAG_NAME_START_REGEXP, TAG_NAME_REPLACEMENT_CHAR)

      return starting_char if name.size == 1

      following_chars = name[1..-1].gsub(TAG_NAME_FOLLOWING_REGEXP, TAG_NAME_REPLACEMENT_CHAR)

      starting_char + following_chars
    end
    module_function :xml_name_escape

    # A utility method for escaping HTML attribute names.
    #
    #   html_attribute_name_escape('><script>alert("boom")</script')
    #   # => "-<script-alert(-boom-)<-script"
    def html_attribute_name_escape(name)
      name.to_s.gsub(ATTRIBUTE_NAME_INVALID_CHARS, '-')
    end
    module_function :html_attribute_name_escape
  end
end

class Object
  def html_safe?
    false
  end
end

ActiveSupport::IntegerClass.class_eval do
  def html_safe?
    true
  end
end

module ActiveSupport #:nodoc:
  class SafeBuffer < String
    def +(other)
      dup.concat(other)
    end

    def html_safe?
      true
    end

    def html_safe
      self
    end

    def to_s
      self
    end

    def to_yaml(*args)
      to_str.to_yaml(*args)
    end
  end
end

class String
  alias safe_concat concat

  def as_str
    self
  end

  def html_safe
    ActiveSupport::SafeBuffer.new(self)
  end

  def html_safe?
    false
  end
end
