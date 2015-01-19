class AddCpuToUsers < ActiveRecord::Migration
  def change
    add_column :users, :cpu_player, :boolean
  end
end
