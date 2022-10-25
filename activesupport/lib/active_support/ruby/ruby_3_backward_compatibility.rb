if RUBY_VERSION >= '3'
  begin
    # require some libraries that will be autopatched by /all
    require 'erb'
    require 'psych'
    require 'uri'

    require 'ruby3_backward_compatibility/compatibility/all'
  rescue LoadError
    fail 'Please add the ruby3-backward-compatibility gem to your Gemfile.'
  end
end
