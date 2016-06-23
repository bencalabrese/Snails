# Snails

Snails is light weight Ruby web framework based on the MVC pattern. It was developed by [Matt Fong](https://github.com/matthewjf), [Andrew Paulson](https://github.com/a-paulson), [Bryan Ng](https://github.com/bryanng412) and [Ben Calabrese](https://github.com/bencalabrese). Though originally a project to better understand how web frameworks work under the hood, it is now fully functional web framework that can be accessed via a command line executable.

## Features & Implementation

### ORM: SQL Objects

Snails implements as fully hand rolled ORM that wraps database rows in Ruby objects. This allows for data to be retrieved and manipulated and using Ruby code. Associations can  be defined at the model level allowing these Ruby objects to correctly implement foreign key associations. While Snails currently only supports SQLite we hope to add PostrgreSQL support in the near future.

```Ruby
#From snails/lib/ORM/sql_object.rb
def self.find(id)
  results = DBConnection.execute(<<-SQL, id)
    SELECT
      *
    FROM
      #{table_name}
    WHERE
      id = ?
  SQL

  results.empty? ? nil : new(results.first)
end

def insert
  col_names = self.class.columns.join(", ")
  question_marks = (["?"] * self.class.columns.length).join(", ")

  DBConnection.execute(<<-SQL, attribute_values)
    INSERT INTO
      #{self.class.table_name} (#{col_names})
    VALUES
      (#{question_marks})
  SQL

  self.id = DBConnection.last_insert_row_id
end
```

### ORM: Stackable and Lazy Queries

Snails' ORM implements a `where` method that is both stackable and lazy. Queries are kept in a relation object as raw SQL until the results of the query are needed. `method_missing` is used to determine when the query needs to be executed. If a relation object is confronted with a method it cannot identify, `method_missing` executes the query, returns a collection of Ruby objects and executes they original method on this collection. Results of run queries are cached to increase speed.

```Ruby
#From snails/lib/ORM/relation.rb
def execute
  return cached_results[subquery] if cached_results[subquery]

  results = DBConnection.execute(subquery, where_vals)

  cached_results[subquery] = opts[:klass].parse_all(results)
end

def subquery
  <<-SQL
    SELECT
      #{opts[:select].join(", ")}
    FROM
      #{opts[:from]}
    WHERE
      #{where_line}
  SQL
end

def method_missing(*args)
  values = execute
  values.send(*args)
end
```

### Routing

Snails implements a rudimentary router that directs html requests to controller actions. In their server file the user creates new routes using a regular expression to specify which URLs to match. When a matching URL is visited a new instance of the controller is created and the specified controller actions is invoked. Controllers can render html written using ERB templates or user specified data such as JSON.

```Ruby
#From snails/lib/controller_and_routing/router.rb
def run(req, res)
  match_data = @pattern.match(req.path)
  route_params = {}
  match_data.names.each do |key|
    route_params[key] = match_data[key]
  end

  ctrl = controller_class.new(req,res, route_params)
  ctrl.invoke_action(@action_name)
end

#From snails/lib/controller_and_routing/controller_base.rb
def render_content(content, content_type)
  response_helper
  @res['Content-Type'] = content_type
  @res.body = [content]
  @res.finish
  session.store_session(@res)
  flash.store_flash(@res)
end
```

### Cookies: Session and Flash storage

Snails implements browser side storage using cookies. Currently two types of storage, flash and session are supported. Flash storage persists through one access while session storage lasts until the user closes the browser.

```Ruby
#From snails/lib/controller_and_routing/flash.rb
def initialize(req)
  cookie = req.cookies['_snails_app_flash']
  @now = (cookie ? JSON.parse(cookie) : {})
  @flash = {}
end

def store_flash(res)
  res.set_cookie('_snails_app_flash', value: @flash.to_json, path: '/')
end
```

### Middleware

Snails uses rack middleware for exception handling and serving static assets. `ExceptionMiddleware` prints the backtrace and searches for the surrounding lines of code if an error is encountered at runtime. `StaticAsset` serves up static assets by using a regular expression to match URLs containing file extensions. It then finds the files and serves them with the correct header using the [FileMagic gem](https://github.com/blackwinter/ruby-filemagic).

```Ruby
#From snails/lib/middleware/exception_middleware.rb
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

#From snails/lib/middleware/static_assets.rb
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

def serve
  res = Rack::Response.new
  file = File.read(file_path)

  res.write(file)
  res['Content-Type'] = FileMagic.new(FileMagic::MAGIC_MIME).file(file_path)
  res.finish
end
```
