class AddOverallScoreToGame < ActiveRecord::Migration
  def change
    add_column :games, :overall_score, :text
  end
end
