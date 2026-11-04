# frozen_string_literal: true

# The generations of every theme created since a moment (`since`; none without it), the window the hourly cap counts over.
class Generations::Query::InWindow < ApplicationQuery
  base_scope { Generation.all }

  pipeline :created_since

  private

  def created_since(current_scope)
    since = filters[:since]
    return current_scope.none unless since

    current_scope.where(created_at: since..)
  end
end
