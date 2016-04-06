require 'rack'
require_relative '../lib/controller_base'

class FlashController < ControllerBase
  @@req_count = 0
    
  def go
    session["count"] ||= 0
    session["count"] += 1
    if @@req_count == 0
      flash["errors"] = ['FLASH ERROR']
      flash.now['error'] = 'NOW ERROR'
    end
    render :flash
    @@req_count += 1
  end
end

app = Proc.new do |env|
  req = Rack::Request.new(env)
  res = Rack::Response.new
  FlashController.new(req, res).go
  res.finish
end

Rack::Server.start(
  app: app,
  Port: 3000
)
