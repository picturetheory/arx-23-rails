#require_relative 'constants'

class Player < ActiveRecord::Base
	belongs_to :user
	belongs_to :game


	def add_player_to_game
		# register my own account on firebase.com
				
		response = FIREBASE.push("games/" + self.game.id.to_s + "/players/", { :name => self.user.email, :priority => 1 })
		#puts response.success? # => true
		#puts response.code # => 200
		#puts response.body # => { 'name' => "-INOQPH-aV_psbk3ZXEX" }
		#puts response.raw_body # => '{"name":"-INOQPH-aV_psbk3ZXEX"}'

	end

end
