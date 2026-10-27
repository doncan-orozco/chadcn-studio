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
    end

    add_index :themes, :slug, unique: true
  end
end
