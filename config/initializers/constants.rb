CARD_VALUES = [
	:diamonds,
	:hearts,
	:clubs,
	:spades
]

BASE_URI = 'https://blinding-torch-3907.firebaseio.com/'
FIREBASE = Firebase::Client.new(BASE_URI)
