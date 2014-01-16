#!/usr/bin/env ruby

require 'rack/contrib'
require 'rack/contrib/backstage'

HOME = "/home/jbardin"

module Rack
class Lint
def call(env = nil)
@app.call(env)
end
end
end

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
          "Location" => request.url.sub("//", "//www.")
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

# https://gist.github.com/207938
require "net/http"

# Example Usage:
#
# use Rack::Proxy do |req|
#   if req.path =~ %r{^/remote/service.php$}
#     URI.parse("http://remote-service-provider.com/service-end-point.php?#{req.query}")
#   end
# end
#
# run proc{|env| [200, {"Content-Type" => "text/plain"}, ["Ha ha ha"]] }
#
class Rack::Proxy
  def initialize(app, &block)
    self.class.send(:define_method, :uri_for, &block)
    @app = app
  end

  def call(env)
    req = Rack::Request.new(env)
    method = req.request_method.downcase
    method[0..0] = method[0..0].upcase

    return @app.call(env) unless uri = uri_for(req)

    sub_request = Net::HTTP.const_get(method).new(uri.to_s) #"#{uri.path}#{"?" if uri.query}#{uri.query}")

    if sub_request.request_body_permitted? and req.body
      sub_request.body_stream = req.body
      sub_request.content_length = req.content_length
      sub_request.content_type = req.content_type
    end

    sub_request["X-Forwarded-For"] = (req.env["X-Forwarded-For"].to_s.split(/, +/) + [req.env['REMOTE_ADDR']]).join(", ")
    sub_request["X-Requested-With"] = req.env['HTTP_X_REQUESTED_WITH'] if req.env['HTTP_X_REQUESTED_WITH']
    sub_request["Accept-Encoding"] = req.accept_encoding
    sub_request["Referer"] = req.referer
    sub_request["Host"] = req.host
    sub_request["Cookie"] = env["HTTP_COOKIE"]
    sub_request.basic_auth *uri.userinfo.split(':') if (uri.userinfo && uri.userinfo.index(':'))

    repeat = 3
    last_exception = nil
    repeat.times { |i|
      sleep 10 if i > 0
      begin
        sub_response = Net::HTTP.start(uri.host, uri.port) do |http|
          http.request(sub_request)
        end

        headers = {}
        sub_response.each_header do |k,v|
          #headers[k] = v unless k.to_s =~ /cookie|content-length|transfer-encoding/i
          headers[k] = v unless k.to_s =~ /content-length|transfer-encoding/i
        end

        return [sub_response.code.to_i, headers, [sub_response.read_body]]
      rescue => e
        last_exception = e
        next if last_exception.is_a?(Errno::ECONNREFUSED)
        break
      end
    }
    raise last_exception
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

map "http://grid.risingcode.com/" do
  #use Rack::Deflater
  run Rack::Directory.new(HOME + "/grid.risingcode.com/public")
end

map "http://nyc.risingcode.com/" do
  use Rack::Deflater
  run Rack::Directory.new(HOME + "/bookmarks/public")
end

map "http://aod.risingcode.com/" do
  use Rack::Proxy do |req|
    new_uri = URI.parse(req.url)
    new_uri.host = "localhost"
    new_uri.port = 9292
    new_uri
  end

  run Proc.new { |env|
    [200, {"Content-Type" => "text/plain"}, [""]]
  }
end

map "http://centerology.risingcode.com/" do
  use Rack::Proxy do |req|
    new_uri = URI.parse(req.url)
    new_uri.host = "ip-10-152-190-228.ec2.internal"
    new_uri.port = 5000
    new_uri
  end

  run Proc.new { |env|
    [200, {"Content-Type" => "text/plain"}, [""]]
  }
end

map "http://thegame.risingcode.com/" do
  #use Rack::Deflater
  run Rack::Directory.new(HOME + "/thegame/public")
end

map "http://rad.risingcode.com/" do
  #use Rack::Deflater
  run Rack::Directory.new(HOME + "/risingcode-rad/public")
end

map "http://portalbloop.risingcode.com/" do
  #use Rack::Deflater
  run Rack::Directory.new(HOME + "/portalbloop/public")
end

map "http://slide.risingcode.com/" do
  run Rack::Directory.new(HOME + "/happy-trails-5/public")
end

map "http://merry-new-year.com/" do
  use Rack::TripleDubRedirect
  run Proc.new { |env|
    [200, {"Content-Type" => "text/plain"}, [""]]
  }
end

map "http://www.merry-new-year.com/" do
  #run Rack::Directory.new(HOME + "/merry-new-year.com/public")
  #use Rack::Static, {:urls => {"/" => 'index.html'}, :root => HOME + "/merry-new-year.com/public"}
  #run Proc.new { |env|
  #  [200, {"Content-Type" => "text/plain"}, [""]]
  #}
  #use Rack::URLMap, {"/" => 'index.html'}
  #run Rack::File.new(HOME + "/merry-new-year.com/public", {:index => HOME + "/merry-new-year.com/public/index.html" })
  use Rack::Static, :urls => ["/merry-new-year.ogg", "/merry-new-year.gif"],
    :root => HOME + "/merry-new-year.com/public"

  #map "/" do
    run lambda { |env|
    [
      200, 
      {
        'Content-Type'  => 'text/html', 
        'Cache-Control' => 'public, max-age=86400' 
      },
      File.open(HOME + "/merry-new-year.com/public/index.html", File::RDONLY)
    ]
  }
  #end
end
