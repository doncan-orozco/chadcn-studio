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

      t.check_constraint "length(prompt) BETWEEN 1 AND 2000", name: "generations_prompt_length"
      t.check_constraint "completed_at IS NULL OR failed_at IS NULL", name: "generations_single_outcome"
      t.check_constraint "(failed_at IS NULL) = (error_code IS NULL)", name: "generations_error_code_iff_failed"
    end
  end
end
