require 'active_support'
require 'active_support/core_ext'
require 'erb'
require_relative './session'
require 'rack'

require 'byebug'

class ControllerBase
  attr_reader :req, :res, :params

  # Setup the controller
  def initialize(req, res, params = {})
    @req = req
    @res = res
    @params = params
    @already_built_response = false
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
  end

  # use ERB and binding to evaluate templates
  # pass the rendered html to render_content
  def render(template_name)
    folder = self.class.to_s[0..-11] + '_' + self.class.to_s[-10..-1]
    file_path = "#{Dir.pwd}/views/#{folder}/#{template_name}.html.erb"

    file = File.open(file_path)
    contents = file.read
    erb_template = ERB.new(contents).result(binding)

    render_content(erb_template, 'text/html')
  end

  # method exposing a `Session` object
  def session
    @session ||= Session.new(@req)
  end

  # use this with the router to call action_name (:index, :show, :create...)
  def invoke_action(name)
    self.send(name)
  end
end
