require_relative 'constants'
# ============================================================
# Card class
# Represents a single playing card (1-10 of hearts/clubs/
# diamonds/spades). 
#
# To initialise, call 
#
# 	Card.new(card_number, card_suit)
#
# where card_number is 1-10, and card_suit is 
# :hearts, :diamonds, :spades, :clubs
#
# Public Methods:
# 	+ output_card	   	  (returns the card value)
#   + self.random_card    (static, generates random card)
# ============================================================
class Card

	attr_accessor :card_number, :card_suit

	def initialize(card_number, card_suit)
		@card_number = check_card_number(card_number)
		@card_suit   = check_card_suit(card_suit)
	end

	def output_card
		self.card_number.to_s + " of " + self.card_suit.to_s
	end

	# STATIC METHOD
	# could say def Card.random_card but this is error prone
	def self.random_card
		#don't use @ here!
		random_suit_number = rand(4)
		Card.new(rand(10), CARD_VALUES[random_suit_number])
	end

	private

		def check_card_number(card_number)
			if card_number.is_a? Integer
				if card_number > 10
					raise ArgumentError, "Card number is greater than 10"
				elsif card_number < 1
					raise ArgumentError, "Card number is less than 1"
				end
			else
				raise ArgumentError, "Card number is not an Integer"
			end
			card_number
		end

		def check_card_suit(card_suit)
			unless CARD_VALUES.include?(card_suit)
				raise ArgumentError, "Card suit is not recognised"
			end
			card_suit
		end

end

