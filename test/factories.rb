FactoryGirl.define do
  
  factory :user, aliases: [:user_1, :user_2, :user_3] do    
    sequence :email do |n|
      "random#{n}@blackjackbaby.com"
    end
    password "omglolhahaha"
    password_confirmation "omglolhahaha"
  end
  
  factory :game do
    status "started"
  end

  factory :player do
    association :user
    association :game
  end

  factory :player_2 do
    association :user, factory: :user_2
    association :game
  end



end
