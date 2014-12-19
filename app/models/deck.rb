require_relative 'card'
# ============================================================
# Deck class
# Represents a playing deck of cards, containing 40 cards
# (1-10 of each suit) which are already shuffled.
#
# To initialise, call
# 	Deck.new
#
# Public Methods:
# 	+ deal_card  	(issue a new card, remove from deck)
# 	+ output_deck   (print out whole deck to command line)
# 	+ num_cards_in_deck  (returns number of cards in deck)
#   + add_cards_to_deck  (adds array of Cards to deck)
#   + reshuffle 	(reshuffle the deck)
# ============================================================
class Deck
	attr_accessor :card_deck

	def initialize
		@card_deck = []
		1.upto(10) do |card_number|
			0.upto(3) do |suit_number|
				@card_deck << Card.new(card_number, CARD_VALUES[suit_number])
			end
		end
		@card_deck.shuffle!
	end

	def deal_card
		self.card_deck.shift
	end

	def output_deck
		self.card_deck.collect do |card|
			card.output_card
		end
	end

	def num_cards_in_deck
		self.card_deck.count
	end

	def add_cards_to_deck(cards)
		cards.each {|card| self.card_deck << card}		
	end

	def reshuffle
		self.card_deck.shuffle!
	end

	def self.test_firebase(message)
		# register my own account on firebase.com
		
		response = FIREBASE.push("games/1", { :name => message, :priority => 1 })
		#puts response.success? # => true
		#puts response.code # => 200
		#puts response.body # => { 'name' => "-INOQPH-aV_psbk3ZXEX" }
		#puts response.raw_body # => '{"name":"-INOQPH-aV_psbk3ZXEX"}'

	end
end

