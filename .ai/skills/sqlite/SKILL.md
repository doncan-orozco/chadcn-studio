---
name: sqlite
description: "SQLite and the Rails 8 stack in chadcn-studio: safe migrations (strong_migrations), database_consistency, Solid Queue/Cache/Cable, Propshaft. Use when creating or editing files in `db/migrate/` or `db/*schema*`, changing columns/indexes/constraints, backfilling data, or configuring Solid services."
---

# Database (SQLite + Rails 8)

## Applies to
- when: `db/migrate/**/*.rb`
- when: `db/*schema*`
- when: `config/{database,queue,cache,cable,recurring}.yml`
- levels: system
- system-review: when-touched

## Quick Rules

Cite as `sqlite R<n>`. Detail and examples follow below / in references/.

R1. **Run database_consistency.** `bundle exec database_consistency` runs after every migration, locally and in CI. → detail: Required: After Migrations
R2. **No direct remove_column.** Removing a column is a 3-deploy sequence: add `ignored_columns`, then remove with `safety_assured`, then delete the `ignored_columns` line. → detail: references/safe-migration-patterns.md
R3. **safety_assured only with ignored_columns.** `safety_assured` is used only when the app already ignores the column and that code is deployed; never as a shortcut. → detail: safety_assured Pattern
R4. **No in-place type change.** Changing a column type uses new column, double-write, batched backfill, read switch, stop old writes, drop old in a separate migration. → detail: references/migration-anti-patterns.md
R5. **No direct rename.** Renaming a column follows the same multi-step copy pattern as a type change, never `rename_column` directly. → detail: references/migration-anti-patterns.md
R6. **Batched backfills.** Backfills use `disable_ddl_transaction!`, `in_batches(of: 10000)` and `sleep(0.01)`; never `update_all` in a transaction or alongside `add_column` in `change`. → detail: references/safe-migration-patterns.md
R7. **NOT NULL on existing columns.** Use a non-validating check constraint, validate it in a separate migration, then `change_column_null` and remove the constraint; never bare `change_column_null`. → detail: references/safe-migration-patterns.md
R8. **Foreign keys unvalidated first.** `add_foreign_key` uses `validate: false`, with `validate_foreign_key` in a separate migration. → detail: references/migration-anti-patterns.md
R9. **Check constraints validate separately.** New check constraints use `validate: false` and are validated in a later migration. → detail: references/safe-migration-patterns.md
R10. **Unique index plus DB constraint.** Uniqueness (a theme's public slug) is enforced at the DB level with a unique index, not only by model validation. → detail: references/migration-anti-patterns.md
R11. **DB check constraints for invariants.** Value rules are backed by `add_check_constraint`, not app validations alone. → detail: references/migration-anti-patterns.md
R12. **Timeouts configured.** `config/initializers/strong_migrations.rb` sets `lock_timeout` and `statement_timeout`. → detail: Migration Timeouts
R13. **New columns declare nullability.** `add_column` with a default specifies `null: false` where the value is required. → detail: references/safe-migration-patterns.md
R14. **Rails 8 Solid stack.** Background jobs, cache and cable use Solid Queue/Cache/Cable on SQLite (`config/queue.yml`, `config/cache.yml`, `config/cable.yml`, `db/*_schema.rb`); assets use Propshaft. → detail: references/rails8-stack.md
R15. **Palettes as JSON columns.** A theme's variables are stored as one `json` column per mode (`light`, `dark`) holding the shadcn variable names as keys, validated by `Chadcn::Theme` before save; never one column per variable (the variable set is the gem's, not the schema's). → `theme-science` R2

## Dependencies
- strong_migrations: prevents unsafe migrations
- database_consistency: audits database integrity

## Core Principle

SQLite scales to millions of rows; treat migrations with Postgres/MySQL rigor to avoid downtime and data corruption. Saved themes and generations are small tables, but the rules cost nothing and keep the habit.

## Required: After Migrations

```bash
bundle exec database_consistency
```

Audits null constraint violations, missing foreign keys, orphaned indexes and counter cache errors.

> **Safe Migration Patterns (strong_migrations):** add/remove/rename/backfill/constraints → [references/safe-migration-patterns.md](references/safe-migration-patterns.md)

## Migration Timeouts

```ruby
# config/initializers/strong_migrations.rb
StrongMigrations.lock_timeout = 10.seconds
StrongMigrations.statement_timeout = 1.hour
```

## safety_assured Pattern

Use ONLY when the operation is certainly safe:

```ruby
class RemoveDeprecatedColumn < ActiveRecord::Migration[8.1]
  def change
    safety_assured { remove_column :themes, :deprecated_field }
  end
end
```

Requires both: the app already ignores the column (`self.ignored_columns += ["deprecated_field"]`) and that code is deployed.

> **Gem Setup and CI Task:** strong_migrations, database_consistency initializers → [references/setup.md](references/setup.md)
> **Playbook:** [references/database.md](references/database.md)
