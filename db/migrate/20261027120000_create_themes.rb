class CreateThemes < ActiveRecord::Migration[8.1]
  def change
    create_table :themes do |t|
      t.string :name, null: false
      t.string :slug, null: false
      t.json :light, null: false
      t.json :dark, null: false
      t.json :inputs, null: false
      t.datetime :published_at

      t.timestamps

      t.check_constraint "slug <> '' AND slug NOT GLOB '*[^a-z0-9-]*'", name: "themes_slug_format"
      t.check_constraint "length(name) BETWEEN 1 AND 80", name: "themes_name_length"
    end

    add_index :themes, :slug, unique: true
  end
end
