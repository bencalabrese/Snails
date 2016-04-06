require 'active_support'
require 'active_support/core_ext'
require 'erb'
require_relative './session'
require_relative './flash'

class ControllerBase
  attr_reader :req, :res, :params

  def self.protect_from_forgery(boolean = true)
    @@protect_from_forgery = boolean
  end

  def self.protect_from_forgery?
    @@protect_from_forgery ||= false
  end

  # Setup the controller
  def initialize(req, res, params = {})
    # byebug
    @req = req
    @res = res
    @params = @req.params.merge(params)
    @already_built_response = false

    csrf_check if self.class.protect_from_forgery?
  end

  def session
    @session ||= Session.new(@req)
  end

  def flash
    @flash ||= Flash.new(@req)
  end

  def form_authenticity_token
    session["authenticity_token"]
  end

  def invoke_action(name)
    self.send(name)
    render(name) unless already_built_response?
  end

  private
  def csrf_check
    if req.get?
      session["authenticity_token"] = SecureRandom.urlsafe_base64(16)
    else
      raise "CSRF ATTACK!" unless
        req.params["authenticity_token"] == form_authenticity_token
    end
  end

  # Helper method to alias @already_built_response
  def already_built_response?
    @already_built_response
  end

  def response_helper
    raise 'error' if already_built_response?
    @already_built_response = true
  end

  # Set the response status code and header
  def redirect_to(url)
    response_helper
    @res.headers['Location'] = url
    @res.status = 302
    session.store_session(@res)
    flash.store_flash(@res)
  end

  # Populate the response with content.
  # Set the response's content type to the given type.
  # Raise an error if the developer tries to double render.
  def render_content(content, content_type)
    response_helper
    @res['Content-Type'] = content_type
    @res.body = [content]
    @res.finish
    session.store_session(@res)
    flash.store_flash(@res)
  end

  # use ERB and binding to evaluate templates
  # pass the rendered html to render_content
  def render(template_name)
    folder = self.class.to_s.underscore.downcase
    file_path = "#{Dir.pwd}/views/#{folder}/#{template_name.to_s}.html.erb"

    file = File.read(file_path)
    erb_template = ERB.new(file).result(binding)

    render_content(erb_template, 'text/html')
  end

  # method exposing a `Session` object

  # use this with the router to call action_name (:index, :show, :create...)
end
