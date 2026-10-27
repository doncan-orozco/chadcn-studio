class CreateGenerations < ActiveRecord::Migration[8.1]
  def change
    create_table :generations do |t|
      t.references :theme, null: false, foreign_key: true
      t.text :prompt, null: false
      t.json :inputs
      t.string :error_code
      t.datetime :started_at
      t.datetime :completed_at
      t.datetime :failed_at

      t.timestamps
    end
  end
end
