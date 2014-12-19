class AddForeignKeyColumnsToPlayers < ActiveRecord::Migration
  def change
  	change_table :players do |t|
  		t.references :user, index: true
  		t.references :game, index: true
  	end
  end
end