require 'test/unit'

class TestDeck < Test::Unit::TestCase

	@game_id = 5

	def test_dealing
		mydeck = set_up_deck
		num_cards_before_deal = mydeck.num_cards_in_deck	
		assert_equal 40, num_cards_before_deal, "Should be 40 cards in a new deck"

		mydeck.deal_card
		num_cards_after_deal = mydeck.num_cards_in_deck
		assert_equal num_cards_before_deal, (num_cards_after_deal + 1), "Should be 1 card less after card is dealt"
	end

	def test_output
		mydeck = set_up_deck
		deck_output = mydeck.output_deck

		deck_output.each do |card|
			assert_match /\d+ of \w/, card, "Card should produce valid output string"
		end

		assert_equal 40, deck_output.count, "Should be 40 cards in a new deck"
	end

	def set_up_deck
		return Deck.new(@game_id)
	end

end