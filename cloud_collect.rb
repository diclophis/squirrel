#!/usr/bin/env ruby

require "activesupport"
require "camping"

Camping.goes :CloudCollect

module CloudCollect::Controllers
  class Index < R('/')
    def get
      render :index
    end
  end
end

module CloudCollect::Views
  def layout
    xhtml_transitional {
      head {
        title {
          "CloudCollect"
        }
      }
      body {
        yield
      }
    }
  end
  def index
    h1 {
      "CloudCollect"
    }
  end
end
