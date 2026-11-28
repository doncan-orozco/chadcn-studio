# frozen_string_literal: true

# The theme the studio's own download may serve: any theme with the given slug, draft or published (the public URL uses
# Exports::Query::Published). Blank slugs find nothing.
class Exports::Query::Downloadable < ApplicationQuery
  base_scope { Theme.all }

  pipeline :with_slug

  private

  def with_slug(current_scope)
    return current_scope.none if filters[:slug].blank?

    current_scope.where(slug: filters[:slug].to_s)
  end
end
