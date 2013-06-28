class CreateGames < ActiveRecord::Migration
  def change
    create_table :games do |t|
      t.string  :short_code,  null: false
      t.text    :game_state

      t.timestamps
    end

    add_index :games, :short_code

  end
end
