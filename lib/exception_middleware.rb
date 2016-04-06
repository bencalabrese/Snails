require 'byebug'
require 'cgi'

class ExceptionMiddleware
  def initialize(app)
    @app = app
  end

  def call(env)
    begin
      @app.call(env)
    rescue RuntimeError => e
      @message = e.message
      @surrounding_lines = CGI.escapeHTML(surrounding_lines(e.backtrace).join(''))
      @stack_trace = CGI.escapeHTML(e.backtrace.join("\n"))
      @res = Rack::Response.new
      @res.status = 500
      render_errors
    end
  end

  def render_content(content, content_type)
    @res["Content-Type"] = content_type
    @res.write(content)

    @res.finish
  end

  def render_errors
    template_path = File.dirname(File.dirname(__FILE__)) + "/views/errors/500.html.erb"

    template_file = File.read(template_path)
    template = ERB.new(template_file)
    render_content(template.result(binding), "text/html")
  end

  def surrounding_lines(backtrace)
    #byebug
   arr = backtrace.first.split(":")

   file_name = arr[0]
   line_number = arr[1].to_i
   start = [0, line_number - 5].max

   File.readlines(file_name).drop(start).take(10)
  end

end
