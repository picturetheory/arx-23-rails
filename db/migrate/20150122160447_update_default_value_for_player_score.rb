class UpdateDefaultValueForPlayerScore < ActiveRecord::Migration
  def change
    change_column :players, :score, :integer, :default => 0
  end
end
