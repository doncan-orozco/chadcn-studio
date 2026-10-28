# frozen_string_literal: true

# The theme a public URL may serve: published, with the given slug. Blank slugs find nothing.
class Exports::Query::Published < ApplicationQuery
  base_scope { Theme.all }

  pipeline :only_published, :with_slug

  private

  def only_published(current_scope) = current_scope.where.not(published_at: nil)

  def with_slug(current_scope)
    return current_scope.none if filters[:slug].blank?

    current_scope.where(slug: filters[:slug].to_s)
  end
end
