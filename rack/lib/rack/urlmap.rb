module Rack
  # Rack::URLMap takes a hash mapping urls or paths to apps, and
  # dispatches accordingly.  Support for HTTP/1.1 host names exists if
  # the URLs start with <tt>http://</tt> or <tt>https://</tt>.
  #
  # URLMap modifies the SCRIPT_NAME and PATH_INFO such that the part
  # relevant for dispatch is in the SCRIPT_NAME, and the rest in the
  # PATH_INFO.  This should be taken care of when you need to
  # reconstruct the URL in order to create links.
  #
  # URLMap dispatches in such a way that the longest paths are tried
  # first, since they are most specific.

  class URLMap
    NEGATIVE_INFINITY = -1.0 / 0.0

    def initialize(map = {})
      remap(map)
    end

    def remap(map)
      @mapping = map.map { |location, app|
        if location =~ %r{\Ahttps?://(.*?)(/.*)}
          host, location = $1, $2
        else
          host = nil
        end

        unless location[0] == ?/
          raise ArgumentError, "paths need to start with /"
        end

        location = location.chomp('/')
        match = if RUBY_VERSION < '3'
          Regexp.new("^#{Regexp.quote(location).gsub('/', '/+')}(.*)", nil, 'n')
        else
          Regexp.new("^#{Regexp.quote(location).gsub('/', '/+')}(.*)", Regexp::NOENCODING)
        end

        [host, location, match, app]
      }.sort_by do |(host, location, _, _)|
        [host ? -host.size : NEGATIVE_INFINITY, -location.size]
      end
    end

    def call(env)
      path = env["PATH_INFO"]
      script_name = env['SCRIPT_NAME']
      hHost = env['HTTP_HOST']
      sName = env['SERVER_NAME']
      sPort = env['SERVER_PORT']

      @mapping.each do |host, location, match, app|
        unless hHost == host \
            || sName == host \
            || (!host && (hHost == sName || hHost == sName+':'+sPort))
          next
        end

        next unless m = match.match(path.to_s)

        rest = m[1]
        next unless !rest || rest.empty? || rest[0] == ?/

        env['SCRIPT_NAME'] = (script_name + location)
        env['PATH_INFO'] = rest

        return app.call(env)
      end

      [404, {"Content-Type" => "text/plain", "X-Cascade" => "pass"}, ["Not Found: #{path}"]]

    ensure
      env['PATH_INFO'] = path
      env['SCRIPT_NAME'] = script_name
    end
  end
end

