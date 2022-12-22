if RUBY_VERSION >= '3'
  # require some libraries that will be autopatched by /all
  require 'erb'
  require 'psych'
  require 'uri'

  begin
    require 'ruby3_backward_compatibility/compatibility/all'
  rescue LoadError
    fail 'Please add the ruby3-backward-compatibility gem to your Gemfile.'
  end

  requirement = '~> 1.0'
  unless Gem::Requirement.new(requirement).satisfied_by?(Gem::Version.new(Ruby3BackwardCompatibility::VERSION))
    fail "Please make sure the ruby3-backward-compatibility gem satisfies '#{requirement}'."
  end
end
