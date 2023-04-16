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

	attr_accessor :card_suit

	def initialize(card_number, card_suit)
		@card_number = check_card_number(card_number)
		@card_suit   = check_card_suit(card_suit)
	end

  def card_number=(value) # Value is generated when the deck is first initialised, in the lines starting with "1.upto(13)"
    if value < 14 && value > 0
      @card_number = value
    else
      raise "card " + value.to_s + " not recognised"
    end
  end

  def card_number
    if @card_number > 10 && @card_number < 14 # If @card_number is 11, 12, or 13 (representing J, Q, K), return its value as 10
      return 10
    elsif @card_number > 1 && @card_number < 11 # If @card_number is between 2 and 10 inclusive, return @card_number as its value
      return @card_number
    elsif @card_number == 1 # If @card_number is 1 (representing an ace), return its value as 11
      return 11
    else
      raise "card " + @card_number.to_s + " not recognised"
    end
  end

	def output_card
    if @card_number == 11
      card_string = "jack"
    elsif @card_number == 12
      card_string = "queen"
    elsif @card_number == 13
      card_string = "king"
    else
      card_string = @card_number.to_s 
    end
		card_string + " of " + self.card_suit.to_s
	end
	
	def self.random_card
		random_suit_number = rand(4)
		Card.new(rand(12)+1, CARD_VALUES[random_suit_number])
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
				if card_number > 13
					raise ArgumentError, "Card number is greater than 13"
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

