# frozen_string_literal: true

# The generations of a theme, newest first; the caller takes the first one.
class Generations::Query::Latest < ApplicationQuery
  base_scope { Generation.all }

  pipeline :newest_first

  private

  def newest_first(current_scope)
    current_scope = current_scope.where(theme_id: filters[:theme_id]) if filters[:theme_id]
    current_scope.order(id: :desc)
  end
end
