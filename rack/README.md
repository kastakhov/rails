# Rack, a modular Ruby webserver interface [![Build Status](https://travis-ci.org/rails-lts/rack.svg?branch=lts-rack-1.4)](https://travis-ci.org/rails-lts/rack)

Rack provides a minimal, modular and adaptable interface for developing web
applications in Ruby.  By wrapping HTTP requests and responses in the simplest
way possible, it unifies and distills the API for web servers, web frameworks,
and software in between (the so-called middleware) into a single method call.

The exact details of this are described in the Rack specification, which all
Rack applications should conform to.

## LTS version

This is a fork of the official [rack gem](https://github.com/rack/rack) with
backported security fixes for:

*   [rack 1.6](https://github.com/rails-lts/rack/tree/lts-1-6-stable)
    (CVE-2020-8161, CVE-2020-8184, CVE-2022-30122, CVE-2022-30123)
*   [rack 1.4](https://github.com/rails-lts/rack/tree/lts-rack-1.4)
    (CVE-2018-16471, CVE-2020-8161, CVE-2020-8184, CVE-2022-30122, CVE-2022-30123)


To use it, you need to add it to the Gemfile like this:

    gem 'rack', git: 'https://github.com/rails-lts/rack.git', branch: 'lts-rack-1.4'

## Supported web servers

The included **handlers** connect all kinds of web servers to Rack:
*   Mongrel
*   EventedMongrel
*   SwiftipliedMongrel
*   WEBrick
*   FCGI
*   CGI
*   SCGI
*   LiteSpeed
*   Thin


These web servers include Rack handlers in their distributions:
*   Ebb
*   Fuzed
*   Glassfish v3
*   Phusion Passenger (which is mod_rack for Apache and for nginx)
*   Puma
*   Rainbows!
*   Unicorn
*   unixrack
*   uWSGI
*   Zbatery


Any valid Rack app will run the same on all these handlers, without changing
anything.

## Supported web frameworks

These frameworks include Rack adapters in their distributions:
*   Camping
*   Coset
*   Halcyon
*   Mack
*   Maveric
*   Merb
*   Racktools::SimpleApplication
*   Ramaze
*   Ruby on Rails
*   Rum
*   Sinatra
*   Sin
*   Vintage
*   Waves
*   Wee
*   ... and many others.


Current links to these projects can be found at
http://wiki.ramaze.net/Home#other-frameworks

## Available middleware

Between the server and the framework, Rack can be customized to your
applications needs using middleware, for example:
*   Rack::URLMap, to route to multiple applications inside the same process.
*   Rack::CommonLogger, for creating Apache-style logfiles.
*   Rack::ShowException, for catching unhandled exceptions and presenting them
    in a nice and helpful way with clickable backtrace.
*   Rack::File, for serving static files.
*   ...many others!


All these components use the same interface, which is described in detail in
the Rack specification.  These optional components can be used in any way you
wish.

## Convenience

If you want to develop outside of existing frameworks, implement your own
ones, or develop middleware, Rack provides many helpers to create Rack
applications quickly and without doing the same web stuff all over:
*   Rack::Request, which also provides query string parsing and multipart
    handling.
*   Rack::Response, for convenient generation of HTTP replies and cookie
    handling.
*   Rack::MockRequest and Rack::MockResponse for efficient and quick testing
    of Rack application without real HTTP round-trips.


## rack-contrib

The plethora of useful middleware created the need for a project that collects
fresh Rack middleware.  rack-contrib includes a variety of add-on components
for Rack and it is easy to contribute new modules.

*   http://github.com/rack/rack-contrib


## rackup

rackup is a useful tool for running Rack applications, which uses the
Rack::Builder DSL to configure middleware and build up applications easily.

rackup automatically figures out the environment it is run in, and runs your
application as FastCGI, CGI, or standalone with Mongrel or WEBrick---all from
the same configuration.

## Quick start

Try the lobster!

Either with the embedded WEBrick starter:

    ruby -Ilib lib/rack/lobster.rb

Or with rackup:

    bin/rackup -Ilib example/lobster.ru

By default, the lobster is found at http://localhost:9292.

## Installing with RubyGems

A Gem of Rack is available at rubygems.org.  You can install it with:

    gem install rack

I also provide a local mirror of the gems (and development snapshots) at my
site:

    gem install rack --source http://chneukirchen.org/releases/gems/

## Running the tests

Testing Rack requires the bacon testing framework:

    bundle install --without extra # to be able to run the fast tests

Or:

    bundle install # this assumes that you have installed native extensions!

There are two rake-based test tasks:

    rake test       tests all the fast tests (no Handlers or Adapters)
    rake fulltest   runs all the tests

The fast testsuite has no dependencies outside of the core Ruby installation
and bacon.

To run a single test you have to use bacon:

    bacon -I./lib test/spec_session_persisted_secure_secure_session_hash.rb

To run the test suite completely, you need:

    * fcgi
    * memcache-client
    * mongrel
    * thin

The full set of tests test FCGI access with lighttpd (on port 9203) so you
will need lighttpd installed as well as the FCGI libraries and the fcgi gem:

Download and install lighttpd:

    http://www.lighttpd.net/download

Installing the FCGI libraries:

    curl -O http://www.fastcgi.com/dist/fcgi-2.4.0.tar.gz
    tar xzvf fcgi-2.4.0.tar.gz
    cd fcgi-2.4.0
    ./configure --prefix=/usr/local
    make
    sudo make install
    cd ..

Installing the Ruby fcgi gem:

    gem install fcgi

Furthermore, to test Memcache sessions, you need memcached (will be run on
port 11211) and memcache-client installed.

## Configuration

Several parameters can be modified on Rack::Utils to configure Rack behaviour.

e.g:

    Rack::Utils.key_space_limit = 128

### key_space_limit

The default number of bytes to allow a single parameter key to take up. This
helps prevent a rogue client from flooding a Request.

Default to 65536 characters (4 kiB in worst case).

### multipart_file_limit

The maximum number of parts with a filename a request can contain. Accepting too many part can
lead to the server running out of file handles.

The default is 128, which means that a single request can't upload more than
128 files at once.

Set to 0 for no limit.

Can also be set via the `RACK_MULTIPART_PART_LIMIT` environment variable.

(This is also aliased as `multipart_part_limit` and `RACK_MULTIPART_PART_LIMIT` for compatibility)

### multipart_total_part_limit

The maximum total number of parts a request can contain of any type, including
both file and non-file form fields.

The default is 4096, which means that a single request can't contain more than
4096 parts.

Set to 0 for no limit.

Can also be set via the `RACK_MULTIPART_TOTAL_PART_LIMIT` environment variable.


## History

*   March 3rd, 2007: First public release 0.1.

*   May 16th, 2007: Second public release 0.2.
    *   HTTP Basic authentication.
    *   Cookie Sessions.
    *   Static file handler.
    *   Improved Rack::Request.
    *   Improved Rack::Response.
    *   Added Rack::ShowStatus, for better default error messages.
    *   Bug fixes in the Camping adapter.
    *   Removed Rails adapter, was too alpha.


*   February 26th, 2008: Third public release 0.3.
    *   LiteSpeed handler, by Adrian Madrid.
    *   SCGI handler, by Jeremy Evans.
    *   Pool sessions, by blink.
    *   OpenID authentication, by blink.
    *   :Port and :File options for opening FastCGI sockets, by blink.
    *   Last-Modified HTTP header for Rack::File, by blink.
    *   Rack::Builder#use now accepts blocks, by Corey Jewett. (See
        example/protectedlobster.ru)
    *   HTTP status 201 can contain a Content-Type and a body now.
    *   Many bugfixes, especially related to Cookie handling.


*   August 21st, 2008: Fourth public release 0.4.
    *   New middleware, Rack::Deflater, by Christoffer Sawicki.
    *   OpenID authentication now needs ruby-openid 2.
    *   New Memcache sessions, by blink.
    *   Explicit EventedMongrel handler, by Joshua Peek <josh@joshpeek.com>
    *   Rack::Reloader is not loaded in rackup development mode.
    *   rackup can daemonize with -D.
    *   Many bugfixes, especially for pool sessions, URLMap, thread safety and
        tempfile handling.
    *   Improved tests.
    *   Rack moved to Git.


*   January 6th, 2009: Fifth public release 0.9.
    *   Rack is now managed by the Rack Core Team.
    *   Rack::Lint is stricter and follows the HTTP RFCs more closely.
    *   Added ConditionalGet middleware.
    *   Added ContentLength middleware.
    *   Added Deflater middleware.
    *   Added Head middleware.
    *   Added MethodOverride middleware.
    *   Rack::Mime now provides popular MIME-types and their extension.
    *   Mongrel Header now streams.
    *   Added Thin handler.
    *   Official support for swiftiplied Mongrel.
    *   Secure cookies.
    *   Made HeaderHash case-preserving.
    *   Many bugfixes and small improvements.


*   January 9th, 2009: Sixth public release 0.9.1.
    *   Fix directory traversal exploits in Rack::File and Rack::Directory.


*   April 25th, 2009: Seventh public release 1.0.0.
    *   SPEC change: Rack::VERSION has been pushed to [1,0].
    *   SPEC change: header values must be Strings now, split on "n".
    *   SPEC change: Content-Length can be missing, in this case chunked
        transfer encoding is used.
    *   SPEC change: rack.input must be rewindable and support reading into a
        buffer, wrap with Rack::RewindableInput if it isn't.
    *   SPEC change: rack.session is now specified.
    *   SPEC change: Bodies can now additionally respond to #to_path with a
        filename to be served.
    *   NOTE: String bodies break in 1.9, use an Array consisting of a single
        String instead.
    *   New middleware Rack::Lock.
    *   New middleware Rack::ContentType.
    *   Rack::Reloader has been rewritten.
    *   Major update to Rack::Auth::OpenID.
    *   Support for nested parameter parsing in Rack::Response.
    *   Support for redirects in Rack::Response.
    *   HttpOnly cookie support in Rack::Response.
    *   The Rakefile has been rewritten.
    *   Many bugfixes and small improvements.


*   October 18th, 2009: Eighth public release 1.0.1.
    *   Bump remainder of rack.versions.
    *   Support the pure Ruby FCGI implementation.
    *   Fix for form names containing "=": split first then unescape
        components
    *   Fixes the handling of the filename parameter with semicolons in names.
    *   Add anchor to nested params parsing regexp to prevent stack overflows
    *   Use more compatible gzip write api instead of "<<".
    *   Make sure that Reloader doesn't break when executed via ruby -e
    *   Make sure WEBrick respects the :Host option
    *   Many Ruby 1.9 fixes.


*   January 3rd, 2010: Ninth public release 1.1.0.
    *   Moved Auth::OpenID to rack-contrib.
    *   SPEC change that relaxes Lint slightly to allow subclasses of the
        required types
    *   SPEC change to document rack.input binary mode in greator detail
    *   SPEC define optional rack.logger specification
    *   File servers support X-Cascade header
    *   Imported Config middleware
    *   Imported ETag middleware
    *   Imported Runtime middleware
    *   Imported Sendfile middleware
    *   New Logger and NullLogger middlewares
    *   Added mime type for .ogv and .manifest.
    *   Don't squeeze PATH_INFO slashes
    *   Use Content-Type to determine POST params parsing
    *   Update Rack::Utils::HTTP_STATUS_CODES hash
    *   Add status code lookup utility
    *   Response should call #to_i on the status
    *   Add Request#user_agent
    *   Request#host knows about forwared host
    *   Return an empty string for Request#host if HTTP_HOST and SERVER_NAME
        are both missing
    *   Allow MockRequest to accept hash params
    *   Optimizations to HeaderHash
    *   Refactored rackup into Rack::Server
    *   Added Utils.build_nested_query to complement Utils.parse_nested_query
    *   Added Utils::Multipart.build_multipart to complement
        Utils::Multipart.parse_multipart
    *   Extracted set and delete cookie helpers into Utils so they can be used
        outside Response
    *   Extract parse_query and parse_multipart in Request so subclasses can
        change their behavior
    *   Enforce binary encoding in RewindableInput
    *   Set correct external_encoding for handlers that don't use
        RewindableInput


*   June 13th, 2010: Tenth public release 1.2.0.
    *   Removed Camping adapter: Camping 2.0 supports Rack as-is
    *   Removed parsing of quoted values
    *   Add Request.trace? and Request.options?
    *   Add mime-type for .webm and .htc
    *   Fix HTTP_X_FORWARDED_FOR
    *   Various multipart fixes
    *   Switch test suite to bacon


*   June 15th, 2010: Eleventh public release 1.2.1.
    *   Make CGI handler rewindable
    *   Rename spec/ to test/ to not conflict with SPEC on lesser operating
        systems


*   March 13th, 2011: Twelfth public release 1.2.2/1.1.2.
    *   Security fix in Rack::Auth::Digest::MD5: when authenticator returned
        nil, permission was granted on empty password.


*   May 22nd, 2011: Thirteenth public release 1.3.0
    *   Various performance optimizations
    *   Various multipart fixes
    *   Various multipart refactors
    *   Infinite loop fix for multipart
    *   Test coverage for Rack::Server returns
    *   Allow files with '..', but not path components that are '..'
    *   rackup accepts handler-specific options on the command line
    *   Request#params no longer merges POST into GET (but returns the same)
    *   Use URI.encode_www_form_component instead. Use core methods for
        escaping.
    *   Allow multi-line comments in the config file
    *   Bug L#94 reported by Nikolai Lugovoi, query parameter unescaping.
    *   Rack::Response now deletes Content-Length when appropriate
    *   Rack::Deflater now supports streaming
    *   Improved Rack::Handler loading and searching
    *   Support for the PATCH verb
    *   [env]('rack.session.options') now contains session options
    *   Cookies respect renew
    *   Session middleware uses SecureRandom.hex


*   May 22nd, 2011: Fourteenth public release 1.2.3
    *   Pulled in relevant bug fixes from 1.3
    *   Fixed 1.8.6 support


*   July 13, 2011: Fifteenth public release 1.3.1
    *   Fix 1.9.1 support
    *   Fix JRuby support
    *   Properly handle $KCODE in Rack::Utils.escape
    *   Make method_missing/respond_to behavior consistent for Rack::Lock,
        Rack::Auth::Digest::Request and Rack::Multipart::UploadedFile
    *   Reenable passing rack.session to session middleware
    *   Rack::CommonLogger handles streaming responses correctly
    *   Rack::MockResponse calls close on the body object
    *   Fix a DOS vector from MRI stdlib backport


*   July 16, 2011: Sixteenth public release 1.3.2
    *   Fix for Rails and rack-test, Rack::Utils#escape calls to_s


*   September 16, 2011: Seventeenth public release 1.3.3
    *   Fix bug with broken query parameters in Rack::ShowExceptions
    *   Rack::Request#cookies no longer swallows exceptions on broken input
    *   Prevents XSS attacks enabled by bug in Ruby 1.8's regexp engine
    *   Rack::ConditionalGet handles broken If-Modified-Since helpers


*   September 16, 2011: Eighteenth public release 1.2.4
    *   Fix a bug with MRI regex engine to prevent XSS by malformed unicode


*   October 1, 2011: Nineteenth public release 1.3.4
    *   Backport security fix from 1.9.3, also fixes some roundtrip issues in
        URI
    *   Small documentation update
    *   Fix an issue where BodyProxy could cause an infinite recursion
    *   Add some supporting files for travis-ci


*   October 17, 2011: Twentieth public release 1.3.5
    *   Fix annoying warnings caused by the backport in 1.3.4


*   December 28th, 2011: Twenty first public release: 1.1.3.
    *   Security fix. http://www.ocert.org/advisories/ocert-2011-003.html
        Further information here: http://jruby.org/2011/12/27/jruby-1-6-5-1


*   December 28th, 2011: Twenty fourth public release 1.4.0
    *   Ruby 1.8.6 support has officially been dropped. Not all tests pass.
    *   Raise sane error messages for broken config.ru
    *   Allow combining run and map in a config.ru
    *   Rack::ContentType will not set Content-Type for responses without a
        body
    *   Status code 205 does not send a response body
    *   Rack::Response::Helpers will not rely on instance variables
    *   Rack::Utils.build_query no longer outputs '=' for nil query values
    *   Various mime types added
    *   Rack::MockRequest now supports HEAD
    *   Rack::Directory now supports files that contain RFC3986 reserved chars
    *   Rack::File now only supports GET and HEAD requests
    *   Rack::Server#start now passes the block to Rack::Handler::<h>#run
    *   Rack::Static now supports an index option
    *   Added the Teapot status code
    *   rackup now defaults to Thin instead of Mongrel (if installed)
    *   Support added for HTTP_X_FORWARDED_SCHEME
    *   Numerous bug fixes, including many fixes for new and alternate rubies


*   January 22nd, 2012: Twenty fifth public release 1.4.1
    *   Alter the keyspace limit calculations to reduce issues with nested
        params
    *   Add a workaround for multipart parsing where files contain unescaped
        "%"
    *   Added Rack::Response::Helpers#method_not_allowed? (code 405)
    *   Rack::File now returns 404 for illegal directory traversals
    *   Rack::File now returns 405 for illegal methods (non HEAD/GET)
    *   Rack::Cascade now catches 405 by default, as well as 404
    *   Cookies missing '--' no longer cause an exception to be raised
    *   Various style changes and documentation spelling errors
    *   Rack::BodyProxy always ensures to execute its block
    *   Additional test coverage around cookies and secrets
    *   Rack::Session::Cookie can now be supplied either secret or old_secret
    *   Tests are no longer dependent on set order
    *   Rack::Static no longer defaults to serving index files
    *   Rack.release was fixed


*   January 6th, 2013: Twenty sixth public release 1.1.4
    *   Add warnings when users do not provide a session secret


*   January 6th, 2013: Twenty seventh public release 1.2.6
    *   Add warnings when users do not provide a session secret
    *   Fix parsing performance for unquoted filenames


*   January 6th, 2013: Twenty eighth public release 1.3.7
    *   Add warnings when users do not provide a session secret
    *   Fix parsing performance for unquoted filenames
    *   Updated URI backports
    *   Fix URI backport version matching, and silence constant warnings
    *   Correct parameter parsing with empty values
    *   Correct rackup '-I' flag, to allow multiple uses
    *   Correct rackup pidfile handling
    *   Report rackup line numbers correctly
    *   Fix request loops caused by non-stale nonces with time limits
    *   Fix reloader on Windows
    *   Prevent infinite recursions from Response#to_ary
    *   Various middleware better conforms to the body close specification
    *   Updated language for the body close specification
    *   Additional notes regarding ECMA escape compatibility issues
    *   Fix the parsing of multiple ranges in range headers


*   January 6th, 2013: Twenty ninth public release 1.4.2
    *   Add warnings when users do not provide a session secret
    *   Fix parsing performance for unquoted filenames
    *   Updated URI backports
    *   Fix URI backport version matching, and silence constant warnings
    *   Correct parameter parsing with empty values
    *   Correct rackup '-I' flag, to allow multiple uses
    *   Correct rackup pidfile handling
    *   Report rackup line numbers correctly
    *   Fix request loops caused by non-stale nonces with time limits
    *   Fix reloader on Windows
    *   Prevent infinite recursions from Response#to_ary
    *   Various middleware better conforms to the body close specification
    *   Updated language for the body close specification
    *   Additional notes regarding ECMA escape compatibility issues
    *   Fix the parsing of multiple ranges in range headers
    *   Prevent errors from empty parameter keys
    *   Added PATCH verb to Rack::Request
    *   Various documentation updates
    *   Fix session merge semantics (fixes rack-test)
    *   Rack::Static :index can now handle multiple directories
    *   All tests now utilize Rack::Lint (special thanks to Lars Gierth)
    *   Rack::File cache_control parameter is now deprecated, and removed by
        1.5
    *   Correct Rack::Directory script name escaping
    *   Rack::Static supports header rules for sophisticated configurations
    *   Multipart parsing now works without a Content-Length header
    *   New logos courtesy of Zachary Scott!
    *   Rack::BodyProxy now explicitly defines #each, useful for C extensions
    *   Cookies that are not URI escaped no longer cause exceptions


*   January 7th, 2013: Thirtieth public release 1.3.8
    *   Security: Prevent unbounded reads in large multipart boundaries


*   January 7th, 2013: Thirty first public release 1.4.3
    *   Security: Prevent unbounded reads in large multipart boundaries


*   January 13th, 2013: Thirty second public release 1.4.4, 1.3.9, 1.2.7,
    1.1.5
        SEC
:           Rack::Auth::AbstractRequest no longer symbolizes arbitrary strings

    *   Fixed erroneous test case in the 1.3.x series


*   February 7th, Thirty fifth public release 1.1.6, 1.2.8, 1.3.10
    *   Fix CVE-2013-0263, timing attack against Rack::Session::Cookie


*   February 7th, Thirty fifth public release 1.4.5
    *   Fix CVE-2013-0263, timing attack against Rack::Session::Cookie
    *   Fix CVE-2013-0262, symlink path traversal in Rack::File


*   February 7th, Thirty fifth public release 1.5.2
    *   Fix CVE-2013-0263, timing attack against Rack::Session::Cookie
    *   Fix CVE-2013-0262, symlink path traversal in Rack::File
    *   Add various methods to Session for enhanced Rails compatibility
    *   Request#trusted_proxy? now only matches whole stirngs
    *   Add JSON cookie coder, to be default in Rack 1.6+ due to security
        concerns
    *   URLMap host matching in environments that don't set the Host header
        fixed
    *   Fix a race condition that could result in overwritten pidfiles
    *   Various documentation additions



## Contact

Please post bugs, suggestions and patches to the bug tracker at
<http://github.com/rack/rack/issues>.

Please post security related bugs and suggestions to the core team at
<https://groups.google.com/group/rack-core> or rack-core@googlegroups.com. Due
to wide usage of the library, it is strongly preferred that we manage timing
in order to provide viable patches at the time of disclosure. Your assistance
in this matter is greatly appreciated.

Mailing list archives are available at
<http://groups.google.com/group/rack-devel>.

Git repository (send Git patches to the mailing list):
*   http://github.com/rack/rack
*   http://git.vuxu.org/cgi-bin/gitweb.cgi?p=rack-github.git


You are also welcome to join the #rack channel on irc.freenode.net.

## Thanks

The Rack Core Team, consisting of

*   Christian Neukirchen (chneukirchen)
*   James Tucker (raggi)
*   Josh Peek (josh)
*   Michael Fellinger (manveru)
*   Ryan Tomayko (rtomayko)
*   Scytrin dai Kinthra (scytrin)
*   Aaron Patterson (tenderlove)
*   Konstantin Haase (rkh)


would like to thank:

*   Adrian Madrid, for the LiteSpeed handler.
*   Christoffer Sawicki, for the first Rails adapter and Rack::Deflater.
*   Tim Fletcher, for the HTTP authentication code.
*   Luc Heinrich for the Cookie sessions, the static file handler and
    bugfixes.
*   Armin Ronacher, for the logo and racktools.
*   Alex Beregszaszi, Alexander Kahn, Anil Wadghule, Aredridel, Ben Alpert,
    Dan Kubb, Daniel Roethlisberger, Matt Todd, Tom Robinson, Phil Hagelberg,
    S. Brent Faulkner, Bosko Milekic, Daniel Rodríguez Troitiño, Genki
    Takiuchi, Geoffrey Grosenbach, Julien Sanchez, Kamal Fariz Mahyuddin,
    Masayoshi Takahashi, Patrick Aljordm, Mig, Kazuhiro Nishiyama, Jon Bardin,
    Konstantin Haase, Larry Siden, Matias Korhonen, Sam Ruby, Simon Chiang,
    Tim Connor, Timur Batyrshin, and Zach Brock for bug fixing and other
    improvements.
*   Eric Wong, Hongli Lai, Jeremy Kemper for their continuous support and API
    improvements.
*   Yehuda Katz and Carl Lerche for refactoring rackup.
*   Brian Candler, for Rack::ContentType.
*   Graham Batty, for improved handler loading.
*   Stephen Bannasch, for bug reports and documentation.
*   Gary Wright, for proposing a better Rack::Response interface.
*   Jonathan Buch, for improvements regarding Rack::Response.
*   Armin Röhrl, for tracking down bugs in the Cookie generator.
*   Alexander Kellett for testing the Gem and reviewing the announcement.
*   Marcus Rückert, for help with configuring and debugging lighttpd.
*   The WSGI team for the well-done and documented work they've done and Rack
    builds up on.
*   All bug reporters and patch contributors not mentioned above.


## Copyright

Copyright (C) 2007, 2008, 2009, 2010 Christian Neukirchen
<http://purl.org/net/chneukirchen>

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

## Links

Rack
:   <http://rack.github.com/>
Official Rack repositories
:   <http://github.com/rack>
Rack Bug Tracking
:   <http://github.com/rack/rack/issues>
rack-devel mailing list
:   <http://groups.google.com/group/rack-devel>
Rack's Rubyforge project
:   <http://rubyforge.org/projects/rack>

Christian Neukirchen
:   <http://chneukirchen.org/>
