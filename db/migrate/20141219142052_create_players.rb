class CreatePlayers < ActiveRecord::Migration
  def change
    create_table :players do |t|
      t.integer :score
      t.string  :status
      t.timestamps
    end
  end
end
