#!/usr/bin/env ruby

HOME = "/home/ubuntu"

require "camping_response_headers_fix"

map "http://cloudcollect.com/" do
  require "cloud_collect"
  use CampingResponseHeadersFix
  run Rack::Adapter::Camping.new(CloudCollect)
end

map "http://risingcode.com/" do
  require HOME + "/risingcode/risingcode"
  require HOME + "/risingcode/boot"
  use CampingResponseHeadersFix
  use Rack::Static, :urls => ["/stylesheets", "/images"], :root => HOME + "/risingcode/public"
  run Rack::Adapter::Camping.new(RisingCode)
end
