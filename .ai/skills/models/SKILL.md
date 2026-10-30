---
name: models
description: "Golden archetype for ActiveRecord models in chadcn-studio. Use when creating or editing any file in `app/models/` or `app/validators/`: strict file layout, no named scopes (use query objects), extracted validators, state predicates, N+1 prevention, no setter shims, JSON palette columns."
---

# Application Active Record Model Pattern

## Applies to
- when: `app/models/**/*.rb`
- when: `app/validators/**/*.rb`
- system-review: never

## Quick Rules

Cite as `models R<n>`. Detail and examples follow below / in references/.

R1. **Strict file layout.** Order: ignored_columns, constants, mixins, third-party macros, associations, callbacks, validations, attributes, public methods, private methods. → detail: Strict File Layout
R2. **No named scopes.** Never declare `scope :x, -> {}`; query logic goes to Query Objects. → detail: No Named Scopes
R3. **Simple validations only.** Models hold only declarative Rails validations; no inline if/else `validates` blocks. → detail: Extract Heavy Validations
R4. **Extract heavy validations.** Multi-association or branching validations go to a Custom Validator in `app/validators/`; the palette validator wraps `Chadcn::Theme.validate` and adds its errors to the record. → detail: references/custom-validators-patterns.md
R5. **State via predicates.** Expose state as consolidated boolean predicates (`published?`, `pending?`); callers never compare raw status or timestamp columns. → detail: State and Booleans Over Raw Status
R6. **Derived status is read-only.** Never define a `status=` (or any setter shim) for derived attributes; state changes go through Operations. → detail: State and Booleans Over Raw Status
R7. **N+1-safe instance methods.** Search loaded associations in memory (`.find`/`detect`) first, falling back to `.find_by`. → detail: N+1 Safety
R8. **Palettes are JSON, typed at the edge.** `light` and `dark` are `json` columns keyed by shadcn variable names; the model exposes them as `Chadcn::Theme::Palette`-shaped values through one reader (`palette`), never as loose hashes scattered through the app. → `sqlite` R15, `theme-science` R2
R9. **No orchestration in models.** No complex business logic, heavy querying, or callbacks that orchestrate write flows; Operations own that. → detail: What Models Are For
R10. **Domain-language names.** Attributes, methods and classes use domain language, not technical jargon. → `naming-conventions`

## What Models Are For

Models represent a **single row of data** from the database. Their responsibility is strictly:
- Define database associations and relationships
- Encapsulate simple validations (presence, length, format, uniqueness)
- Expose derived state checks (boolean predicates like `published?`, `pending?`)
- Configure third-party macros tied directly to the database

Models are **NOT** for complex business logic (Operations), heavy querying (Query Objects), heavy validation logic (Custom Validators), state mutation orchestration (Operations), color math (`Themes::Service::Harmony`) or setter shims for read-only derived attributes.

## The models of this app

```ruby
# app/models/theme.rb
class Theme < ApplicationRecord
  SLUG_FORMAT = /\A[a-z0-9-]+\z/

  has_many :generations, dependent: :destroy

  validates :name, presence: true, length: { maximum: 80 }
  validates :slug, presence: true, uniqueness: true, format: { with: SLUG_FORMAT }
  validates_with PaletteValidator

  def palette = Chadcn::Theme::Palette.new(root: light, dark: dark)

  def published? = published_at.present?
end

# app/models/generation.rb
class Generation < ApplicationRecord
  belongs_to :theme

  validates :prompt, presence: true, length: { maximum: 2000 }

  def pending? = completed_at.nil? && failed_at.nil?
  def failed? = failed_at.present?
end
```

## Strict File Layout

1. `self.ignored_columns` (only during a migration safety window)
2. Constants
3. Mixins (`extend`, `include`)
4. Third-party macros tied to the database
5. Associations
6. Callbacks
7. Validations (`validates`, `validates_with`)
8. Attributes (`attr_reader`, rare)
9. Public instance methods (state checks, simple readers)
10. Private methods

## No Named Scopes

Scopes leak query logic into the model and grow into untestable SQL chains. All query logic goes to Domain Query Objects (`query-object-pattern`): `Themes::Query::Recent`, `Themes::Query::Published`.

## Extract Heavy Validations

```ruby
# app/validators/palette_validator.rb
class PaletteValidator < ActiveModel::Validator
  def validate(record)
    result = Chadcn::Theme.validate(record.palette, strict: false)
    result[:errors].each { |message| record.errors.add(:base, message) }
  end
end
```

The validator is the only place a model touches `Chadcn::Theme`; it never re-implements a check.

## State and Booleans Over Raw Status

Consolidate overlapping state checks into semantic predicates; `status` (if ever needed) is derived and read-only. Transitions are operations (`Themes::Operation::Publish`), never a setter.

## N+1 Safety

Instance methods that walk an association use the loaded collection first:

```ruby
def latest_generation
  generations.loaded? ? generations.max_by(&:created_at) : generations.order(created_at: :desc).first
end
```

> **Custom validators:** [references/custom-validators-patterns.md](references/custom-validators-patterns.md)

## Related Skills & Boundaries

1. **[`query-object-pattern`](../query-object-pattern/SKILL.md)** for finding or filtering collections.
2. **[`operation-pattern`](../operation-pattern/SKILL.md)** for create/update/delete and transitions.
3. **[`theme-science`](../theme-science/SKILL.md)** for what a palette holds.
4. **[`naming-conventions`](../naming-conventions/SKILL.md)** for names.

## Verification Checklist

- [ ] Layout is strict
- [ ] No named scopes
- [ ] No complex logic in validations (extracted to Custom Validators)
- [ ] State checks are boolean predicates
- [ ] No setter shims for read-only attributes
- [ ] N+1-safe instance methods
- [ ] Palette columns are JSON keyed by variable name, validated through `Chadcn::Theme`
- [ ] No ActiveRecord callbacks orchestrating write flows
