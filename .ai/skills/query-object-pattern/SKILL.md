---
name: query-object-pattern
description: "Golden archetype for read Query Objects in chadcn-studio. Use when creating or editing files in `app/concepts/*/query/`: plain ActiveRecord results, hash conditions over raw SQL, unfiltered base scope with a filter pipeline, no pagination in queries."
---

# Application Query Object Pattern

## Quick Rules

Cite as `query-object-pattern R<n>`. Detail and examples follow below / in references/.

R1. **Plain AR records only.** Never use `select` aliases or computed columns that add virtual attributes; select only schema columns. → detail: Records Must Be Plain ActiveRecord Models
R2. **Unfiltered base scope.** `base_scope` returns the full domain collection (`Model.all`); no `where` filters in it. → detail: Base Scope Must Be the Root of Your Domain
R3. **Filters live in pipeline steps.** Every filter is a named step declared with the `pipeline` macro. → detail: Style Rules
R4. **Pure private step methods.** One filter per private method taking `(current_scope)`, guard clauses, returning the scope; never mutate instance state. → detail: Style Rules
R5. **Single entry point.** Public interface is only `.call(filters, scope: nil)`; no keyword-argument call forms; honor a passed `scope:`. → detail: Interface Constraints
R6. **Never paginate.** Return a plain unpaginated `ActiveRecord::Relation`; pagination is the caller's job. → detail: Responsibilities
R7. **ORM over raw SQL.** Use hash/array conditions; no string conditions or interpolated SQL with user input; sanitize LIKE input. → detail: references/orm-conditions.md
R8. **Sort allowlist.** Validate sort field and direction against a strict allowlist before ordering. → detail: Style Rules
R9. **Boundary short-circuit.** A strict-boundary step returns `current_scope.none` when context is missing, never `current_scope`. → detail: Mandatory Context Short-Circuits
R10. **Normalize boolean filters.** Cast form-sourced boolean filters with `ActiveModel::Type::Boolean`. → detail: Boolean Filter Normalization
R11. **Domain naming, no God Queries.** Inherit `ApplicationQuery`, live in `app/concepts/<domain>/query/`, name by business boundary (`Themes::Query::Recent`, `Themes::Query::Published`), one boundary per class. → detail: Conventions
R12. **Aggregates stay out of records.** Computed counts/derived data go in a separate hash/struct or presenter, not the query's select. → detail: Records Must Be Plain ActiveRecord Models

## Responsibilities
- Build an ActiveRecord relation for read concerns only.
- Encapsulate visibility rules and domain boundaries (`Published`, `Recent`).
- Apply search and sorting.
- Return a plain `ActiveRecord::Relation`; the caller paginates.
- Expose only `.call(filters, scope: nil)`.

## Records Must Be Plain ActiveRecord Models

Never use `SELECT` to attach virtual attributes, computed columns or aliases. Aggregates (how many generations a theme had) are computed separately (`group(...).count` into a Hash) or in a presenter.

## Base Scope Must Be the Root of Your Domain

`base_scope { Theme.all }`; every filter is a pipeline step, so a caller's `scope:` composes and a reader sees the filters in the `pipeline` declaration.

```ruby
module Themes
  module Query
    class Published < ApplicationQuery
      base_scope { Theme.all }

      pipeline :filter_published, :filter_by_name, :apply_ordering

      private

      def filter_published(current_scope) = current_scope.where.not(published_at: nil)

      def filter_by_name(current_scope)
        return current_scope if filters[:name].blank?

        current_scope.where("name LIKE ?", "%#{ActiveRecord::Base.sanitize_sql_like(filters[:name])}%")
      end

      def apply_ordering(current_scope)
        field = ALLOWED_SORT.fetch(filters[:sort], :created_at)
        current_scope.order(field => :desc)
      end
    end
  end
end
```

## Conventions
- Inherit from `ApplicationQuery` (`app/queries/application_query.rb`; base class and examples in references/base-class-and-examples.md).
- Group by domain module, name the class after the business boundary, no stuttering (`Recent`, not `RecentQuery`).
- `base_scope { Model.all }`; declare the sequence with `pipeline`; one filter per private method; pure methods.
- Validate sorting inputs against an allowlist; normalize boolean filters with `ActiveModel::Type::Boolean`.
- Eager loading is a final pipeline step when the boundary guarantees association access in callers.

### Mandatory Context Short-Circuits
A step that enforces a boundary returns `current_scope.none` when the context is missing.

### Boolean Filter Normalization
```ruby
def filter_by_published(current_scope)
  return current_scope unless filters.key?(:published)

  published = ActiveModel::Type::Boolean.new.cast(filters[:published])
  published ? current_scope.where.not(published_at: nil) : current_scope.where(published_at: nil)
end
```

## Interface Constraints
- The accepted signature is strictly `.call(filters, scope: nil)`.

## Spec Checklist
- `.call` returns a plain `ActiveRecord::Relation` (not paginated)
- Optional `scope:` is honored over `base_scope`
- `QueryObject.call({})` returns the base relation
- Case-insensitive name filter protects against wildcard injection
- Ordering enforces the allowed fields

> **Base class and examples:** [references/base-class-and-examples.md](references/base-class-and-examples.md) · **Filters and search:** [references/filters-and-search.md](references/filters-and-search.md) · **ORM conditions:** [references/orm-conditions.md](references/orm-conditions.md)
