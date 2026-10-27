# Model Examples

Models are for persistence only - associations only. Code examples below.

## Database Constraints (Migration)

```ruby
# db/migrate/xxx_create_themes.rb
class CreateThemes < ActiveRecord::Migration[8.0]
  def change
    create_table :themes do |t|
      t.string :title, null: false
      t.string :slug, null: false
      t.string :status, null: false
      t.references :generation, null: false, foreign_key: { to_table: :users }
      t.timestamps

      t.index :slug, unique: true
      t.check_constraint "status IN ('draft', 'published', 'archived')", name: "valid_status"
    end
  end
end
```

## Model (Persistence Layer)

```ruby
# app/models/theme.rb
class Theme < ApplicationRecord
  belongs_to :generation, class_name: "User"
  has_many :comments, dependent: :destroy

  normalizes :title, with: -> { _1.strip }
  normalizes :slug, with: -> { _1.strip.downcase }

  # Optional: Safety-net validations (paranoid mode, prevents bad data if contract bypassed)
  validates :title, presence: true
  validates :status, inclusion: { in: %w[draft published archived] }
end
```

## Query Object (Read Queries)

```ruby
# app/queries/theme/published_query.rb
module Theme
  class PublishedQuery
    def self.call
      ::Theme.where(status: "published").order(created_at: :desc)
    end
  end
end
```

## Contract (Business Validation)

```ruby
# app/contracts/theme/contract/create.rb
module Theme
  module Contract
    class Create < Dry::Validation::Contract
      params do
        required(:title).filled(:string, max_size?: 255)
        required(:slug).filled(:string, format?: /\A[a-z0-9-]+\z/)
        required(:status).filled(:string, included_in?: %w[draft published])
        required(:generation_id).filled(:integer)
      end

      # Complex cross-field validation
      rule(:title, :status) do
        if values[:status] == "published" && values[:title].length < 10
          key(:title).failure("must be at least 10 characters for published themes")
        end
      end
    end
  end
end
```

