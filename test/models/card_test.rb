require 'test/unit'

class TestCard < Test::Unit::TestCase

	def test_good_card
		card = Card.new(5,:diamonds)
		expected = "5 of diamonds"
		actual = card.output_card
		assert_equal expected, actual, "Should be able to create a 5 of diamonds card"
	end

	def test_bad_cards
		assert_raise ArgumentError, "Can't create card with suit of monkeys" do 
			Card.new(5,:monkeys)
		end

		assert_raise ArgumentError, "Can't create card with number > 10" do 
			card = Card.new(15,:diamonds)
		end

		assert_raise ArgumentError, "Can't create card with number < 1" do 
			card = Card.new(-1,:diamonds)
		end

		assert_raise ArgumentError, "Can't create card with non-numeric number" do 
			card = Card.new("abs",:diamonds)
		end
	end

	def test_random_card
		card = Card.random_card
		assert_match /\d+ of \w/, card.output_card, "Randomly generated card should be valid"
	end

	def test_to_json
		card = Card.new(5,:diamonds)		
		assert valid_json?(card.to_json), "Serialised card should be in valid json"
	end

	def test_from_json
		card = Card.new(5,:diamonds)
		card_in_json = card.to_json
		new_card = Card.from_json(card_in_json)
		assert_equal 5, new_card.card_number, "Deserialised card should return initial card number"
		assert_equal :diamonds, new_card.card_suit, "Deserialised card should return initial card suit"
	end

	# helper function from https://gist.github.com/ascendbruce/7070951
	def valid_json?(json)
	  begin
	    JSON.parse(json)
	    return true
	  rescue Exception => e
	    return false
	  end
	end

end