class AddFinishedToGames < ActiveRecord::Migration
  def change
    add_column :games, :finished, :boolean, null: false, default: false
    add_column :games, :winner, :string
  end
end
