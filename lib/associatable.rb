require 'active_support/inflector'

# Phase IIIa
class AssocOptions
  attr_accessor(
    :foreign_key,
    :class_name,
    :primary_key
  )

  def model_class
    class_name.constantize
  end

  def table_name
    model_class.table_name
  end
end

class BelongsToOptions < AssocOptions
  def initialize(name, options = {})
    defaults = {
      foreign_key: "#{name}_id".to_sym,
      primary_key: :id,
      class_name: "#{name}".camelcase
    }

    options = defaults.merge(options)

    @foreign_key = options[:foreign_key]
    @primary_key = options[:primary_key]
    @class_name = options[:class_name]
  end
end

class HasManyOptions < AssocOptions
  def initialize(name, self_class_name, options = {})
    defaults = {
      foreign_key: "#{self_class_name.downcase}_id".to_sym,
      primary_key: :id,
      class_name: name.to_s.singularize.camelcase
    }

    options = defaults.merge(options)

    @foreign_key = options[:foreign_key]
    @primary_key = options[:primary_key]
    @class_name = options[:class_name]
  end
end

module Associatable
  # Phase IIIb
  def belongs_to(name, options = {})
    options = BelongsToOptions.new(name, options)
    assoc_options[name] = options

    define_method(name) do
      results = options.model_class.where({options.primary_key => send(options.foreign_key)})
      results.first
    end
  end

  def has_many(name, options = {})
    options = HasManyOptions.new(name, self.to_s, options)

    define_method(name) do
      results = options.model_class.where({options.foreign_key => send(options.primary_key)})
    end
  end

  def assoc_options
    @assoc_options ||= {}
  end

  def has_one_through(name, through_name, source_name)
    through_options = assoc_options[through_name]
    source_options =
      through_options.model_class.assoc_options[source_name]


    define_method(name) do
      from_line = <<-SQL
        #{through_options.table_name}
        JOIN #{source_options.table_name}
        ON #{source_options.table_name}.#{through_options.primary_key} =
        #{through_options.table_name}.#{source_options.foreign_key}
      SQL

      where_line = <<-SQL
        #{through_options.table_name}.#{through_options.primary_key} =
        #{self.send(through_options.foreign_key)}
      SQL

      results = DBConnection.execute(<<-SQL)
        SELECT
          #{source_options.table_name}.*
        FROM
          #{from_line}
        WHERE
          #{where_line}
      SQL

      source_options.model_class.parse_all(results).first
    end
  end
end
