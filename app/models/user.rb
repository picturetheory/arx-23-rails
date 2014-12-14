class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  def get_player_score
  	if self.games_won.nil?
  		return 0
  	else
  		return self.games_won
  	end
  end

  def is_signed_in?
  	if self.current_sign_in_ip.nil?
  		return false
  	else
  		return true
  	end
  end
end
