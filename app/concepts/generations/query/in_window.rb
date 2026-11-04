# frozen_string_literal: true

# The generations of every theme created since a moment (`since`), the window the hourly cap counts over.
class Generations::Query::InWindow < ApplicationQuery
  base_scope { Generation.all }

  pipeline :created_since

  private

  def created_since(current_scope)
    return current_scope unless filters[:since]

    current_scope.where(created_at: filters[:since]..)
  end
end
