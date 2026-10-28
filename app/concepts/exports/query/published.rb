# frozen_string_literal: true

# The one theme a public URL may serve: published, by slug. Unpublished or unknown slugs find nothing.
class Exports::Query::Published
  def self.call(slug) = Theme.where.not(published_at: nil).find_by(slug: slug.to_s)
end
