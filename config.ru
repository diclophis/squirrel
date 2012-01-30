#!/usr/bin/env ruby

HOME = "/home/jbardin"

=begin
map "http://cloudcollect.com/" do
  require "cloud_collect"
  use CampingResponseHeadersFix
  run Rack::Adapter::Camping.new(CloudCollect)
end
=end

=begin
map "http://veejay.tv/" do
  Dir.chdir(HOME + "/veejaytv/")
  require HOME + "/veejaytv/config/environment"
  run Veejaytv::Application
end
=end

=begin
map "http://veejay.tv/" do
  Dir.chdir(HOME + "/veejaytv/")
  #use Rack::Static, :urls => ["/"], :root => HOME + "/veejaytv/public"
  require HOME + "/veejaytv/config/environment"
  run Veejaytv::Application
end
=end

map "http://risingcode.com/" do
  require HOME + "/risingcode.com/risingcode"
  require HOME + "/risingcode.com/boot"
  use Rack::StaticCache, :urls => ["/favicon.ico", "/stylesheets", "/images", "/javascripts", "/webgl"], :root => HOME + "/risingcode/public"
  run RisingCode
end

map "http://emscripten.risingcode.com/" do
  run Rack::Directory.new(HOME + "/emscripten.risingcode.com/public")
end
