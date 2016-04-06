require_relative 'relation'

module Searchable
  def where(params)
    relation = Relation.new(
      klass: self,
      where_pairs: params,
      from: table_name
    )
  end
end
