# frozen_string_literal: true

# The theme an export URL may serve: published, with the given slug (`include_drafts: true` lets the studio's own download
# reach a draft too). Blank slugs find nothing.
class Exports::Query::Published < ApplicationQuery
  base_scope { Theme.all }

  pipeline :only_published, :with_slug

  private

  def only_published(current_scope)
    return current_scope if filters[:include_drafts]

    current_scope.where.not(published_at: nil)
  end

  def with_slug(current_scope)
    return current_scope.none if filters[:slug].blank?

    current_scope.where(slug: filters[:slug].to_s)
  end
end
