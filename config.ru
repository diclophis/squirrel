#!/usr/bin/env ruby

HOME = "/home/ubuntu"

require "camping_response_headers_fix"
require "rack_proctitle"

map "http://cloudcollect.com/" do
  require "cloud_collect"
  use CampingResponseHeadersFix
  run Rack::Adapter::Camping.new(CloudCollect)
end

map "http://risingcode.com/" do
  require HOME + "/risingcode/risingcode"
  require HOME + "/risingcode/boot"
  use CampingResponseHeadersFix
  use RackProctitle, :prefix => "risingcode"
  use Rack::Static, :urls => ["/stylesheets", "/images"], :root => HOME + "/risingcode/public"
  run Rack::Adapter::Camping.new(RisingCode)
end
