#!/usr/bin/env ruby

=begin
class CampingResponseHeadersFix
  def initialize(app)
    @app = app
  end

  def call(env)
    res = @app.call(env)
    res[1]["Set-Cookie"] = JSON.dump(res[1]["Set-Cookie"]) if res[1]["Set-Cookie"]
    res
  end
end
=end
