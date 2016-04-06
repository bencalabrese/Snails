require 'filemagic'

class StaticAsset

  attr_reader :app, :req

  def initialize(app)
    @app = app
  end

  def call(env)
    @req = Rack::Request.new(env)
    #matches multiple periods
    static_asset_regex = Regexp.new('^\/[^\/|\.]+(\.\w+)+')

    if req.path.match(static_asset_regex) && matched_file?
      serve
    else
      app.call(env)
    end
  end

  private

  def file_path
    "./public#{req.path}"
  end

  def serve
    res = Rack::Response.new
    file = File.read(file_path)

    res.write(file)
    res['Content-Type'] = FileMagic.new(FileMagic::MAGIC_MIME).file(file_path)
    res.finish
  end

  def matched_file?
    File.exist?(file_path)
  end
end
