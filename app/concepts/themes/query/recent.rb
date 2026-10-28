# frozen_string_literal: true

# Every theme, newest first.
class Themes::Query::Recent < ApplicationQuery
  base_scope { Theme.all }

  pipeline :newest_first

  private

  def newest_first(current_scope) = current_scope.order(created_at: :desc, id: :desc)
end
