require 'rack'
require_relative '../lib/controller_base'
require_relative '../lib/static_assets'

class AssetController < ControllerBase
  def go

  end
end


app = Proc.new do |env|
  req = Rack::Request.new(env)
  res = Rack::Response.new
  AssetController.new(req, res).go
  res.finish
end

Rack::Server.start(
  app: app,
  Port: 3000
)
