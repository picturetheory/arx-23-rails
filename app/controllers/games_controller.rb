class GamesController < ApplicationController
	def index
		@users = User.all
	end

	def new
		deck = Deck.new
		@hand = []
		@hand << deck.deal_card
		@hand << deck.deal_card
	end
end
