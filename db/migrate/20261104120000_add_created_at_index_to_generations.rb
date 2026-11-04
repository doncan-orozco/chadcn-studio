# The hourly generation cap counts every generation created in the last hour (Generations::Query::InWindow).
class AddCreatedAtIndexToGenerations < ActiveRecord::Migration[8.1]
  def change
    add_index :generations, :created_at
  end
end
