module ApplicationHelper

  def get_player_label(current_user_id, player)
    if current_user.id == player.user.id 
      return "You"
    else
      return player.user.email
    end
  end

  def player_row_highlighting(current_user_id, player)
    if current_user_id == player.user.id 
      return "class=success"
    end
  end

  def winner_row_highlighting(player)
    if player.status == "winner"
      return "class=danger"
    end
  end

  def fb_prefix
    if Rails.env.production?
      prefix = "p/"
    else
      prefix = "d/"
    end
  end
end
