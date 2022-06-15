# This file is only required on Ruby 3+

module ActiveSupport
  def self.call_with_keywords(object, method, args, keyword_args)
    object.public_send(method, *args, **keyword_args)
  end
end
