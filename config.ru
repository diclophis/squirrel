#!/usr/bin/env ruby

require 'rack/contrib'
require 'rack/contrib/backstage'

HOME = "/home/jbardin"

module Rack
  class TripleDubRedirect
    def initialize(app)
      @app = app
    end

    def call(env)
      request = Rack::Request.new(env)
      #env['HTTP_IF_NONE_MATCH'] = $build + request.url
      unless request.host.start_with?("www.")
        [301, {
          'Content-Type' => "text/plain",
          "Location" => request.url.sub("//www.", "//")
        }, self]
      else
        @app.call(env)
      end
    end

    def each(&block)
    end
  end

  class CanonicalHost
    def initialize(app, host=nil, &block)
      @app = app
      @host = (block_given? && block.call) || host
    end

    def call(env)
      if url = url(env)
        [301, { 'Location' => url }, ['Redirecting...']]
      else
        @app.call(env)
      end
    end

    def url(env)
      if @host && env['SERVER_NAME'] != @host
        url = Rack::Request.new(env).url
        url.sub(%r{\A(https?://)(.*?)(:\d+)?(/|$)}, "\\1#{@host}\\3/")
      end
    end
    private :url
  end

end


map "http://risingcode.com/" do
  run Proc.new { |env|
    request = Rack::Request.new(env)
    corrected_url = request.url.gsub(/^http:\/\/risingcode.com/, "http://www.risingcode.com")
    [301, {
      'Content-Type' => "text/plain",
      "Location" => corrected_url 
    }, ['Redirecting...']]
  }
end

map "http://www.risingcode.com/" do
  require HOME + "/risingcode.com/risingcode"
  require HOME + "/risingcode.com/boot"
  use Rack::Backstage, "risingcode.html"
  use Rack::StaticCache, :urls => ["/favicon.ico", "/muni", "/stylesheets", "/images", "/javascripts", "/webgl"], :root => HOME + "/risingcode.com/public"
  run RisingCode
end

map "http://gladius.risingcode.com/" do
  run Rack::Directory.new(HOME + "/gladius.risingcode.com/public")
end

map "http://nocomply.risingcode.com/" do
  run Rack::Directory.new(HOME + "/nocomply.risingcode.com/public")
end

map "http://emscripten.risingcode.com/" do
  use Rack::Deflater
  use Rack::StaticCache, :urls => ["/assets", "raptor_island.js", "index.html"], :root => HOME + "/emscripten.risingcode.com/public", :duration => (30.0 / (60.0 * 60.0 * 24.0 * 365.0))
  run Rack::Directory.new(HOME + "/emscripten.risingcode.com/public")
end

map "http://modgraphz.risingcode.com/" do
  run Rack::Directory.new(HOME + "/modgraphz.risingcode.com/public")
end

map "http://sdlaudio.risingcode.com/" do
  use Rack::Deflater
  run Rack::Directory.new(HOME + "/sdlaudio.risingcode.com/public")
end

map "http://ctr.risingcode.com/" do
  use Rack::Deflater
  run Rack::Directory.new(HOME + "/ctr.risingcode.com/public")
end
