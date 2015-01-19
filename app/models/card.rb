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
	
	def self.random_card
		random_suit_number = rand(4)
		Card.new(rand(9)+1, CARD_VALUES[random_suit_number])
	end

	# serialise card object to json
	def to_json
		{'card_number' => @card_number, 'card_suit' => @card_suit}.to_json	
	end

	# deserialise card object from json
	def self.from_json(string)
		data = JSON.load(string)
		if data['card_suit'] == "clubs"
			card_suit = :clubs
		elsif data['card_suit'] == "diamonds"
			card_suit = :diamonds
		elsif data['card_suit'] == "spades"
			card_suit = :spades
		elsif data['card_suit'] == "hearts"
			card_suit = :hearts
		else
			return nil
		end
		self.new(data['card_number'], card_suit)
	end

  def self.get_card_image(card)
    return "cards/" + (card.gsub! " ", "_") + ".png" 
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

