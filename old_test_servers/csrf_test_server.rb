require 'rack'
require_relative '../lib/controller_base'
require_relative '../lib/router'
require_relative  '../lib/exception_middleware'
require_relative '../views/errors/test_me'
require_relative '../lib/static_assets'

$cats = [
  { id: 1, name: "Curie" },
  { id: 2, name: "Markov" }
]

$statuses = [
  { id: 1, cat_id: 1, text: "Curie loves string!" },
  { id: 2, cat_id: 2, text: "Markov is mighty!" },
  { id: 3, cat_id: 1, text: "Curie is cool!" }
]

class ApplicationContoller < ControllerBase
  protect_from_forgery
end

class CatsController < ApplicationContoller
  def index
    @cats = $cats
    render :index
  end

  def new
    render :new
  end

  def create
    flash.now["test"] = "It worked!"
    render :index
  end
end


router = Router.new
router.draw do
  get Regexp.new("^/cats$"), CatsController, :index
  get Regexp.new("^/cats/new$"), CatsController, :new
  post Regexp.new("^/cats$"), CatsController, :create
end

app_proc = Proc.new do |env|
  req = Rack::Request.new(env)
  res = Rack::Response.new
  router.run(req, res)
  res.finish
end

app = Rack::Builder.app do
  use ExceptionMiddleware
  use StaticAsset
  run app_proc
end



Rack::Server.start(
 app: app,
 Port: 3000
)
