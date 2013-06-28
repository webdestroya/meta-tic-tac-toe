class AddTurnToGame < ActiveRecord::Migration
  def change
    add_column :games, :turn, :string, null: false, default: 'X'
  end
end
