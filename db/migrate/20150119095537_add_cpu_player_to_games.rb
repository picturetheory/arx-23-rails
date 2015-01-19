class AddCpuPlayerToGames < ActiveRecord::Migration
  def change
    add_column :games, :cpu_player, :boolean
  end
end
