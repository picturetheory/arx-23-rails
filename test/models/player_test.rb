require 'test_helper'

class PlayerTest < ActiveSupport::TestCase

	test "test player card functionality"  do
		player = FactoryGirl.create(:player)

		player.create_hand
		assert_equal 0, player.total_num_cards, "Initialised player should have no cards"
		assert_equal 0, player.total_value_cards, "Initialised player with no cards should have a card total value of zero"

		c1 = Card.new(5, :diamonds)
		c2 = Card.new(10, :spades)

		player.get_new_card(c1)
		player.get_new_card(c2)

		assert_equal 2, player.total_num_cards, "Player should have 2 cards"
		assert_equal 15, player.total_value_cards, "Player should have card value of 15"

		player_hand_output = player.output_hand

		player_hand_output.each do |card|
			assert_match /\d+ of \w/, card, "Each Player card should produce valid output string"
		end
	end

end
