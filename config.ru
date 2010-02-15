#!/usr/bin/env ruby

HOME = "/home/ubuntu"

require "cloud_collect"
require "camping_response_headers_fix"
require HOME + "/risingcode/risingcode"

map "http://cloudcollect.com/" do
  use CampingResponseHeadersFix
  run Rack::Adapter::Camping.new(CloudCollect)
end

map "http://risingcode.com/" do
  use CampingResponseHeadersFix
  run Rack::Adapter::Camping.new(RisingCode)
end
