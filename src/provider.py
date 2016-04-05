class Provider: 
	""" A service provider for bike stations.

	Attributes:
		id: provider id
		inventory: available units
		profit: money earned through servicing stations
		priceList: service level and their prices - level 1 takes 3 days, level 2 takes 2 days, level 3 takes 1 day
	"""
	_inventory = 2
	_profit = 0
	
	def __init__(self, id=1, priceList={1:10, 2:15, 3:25}):
		self.id = id
		self.priceList = priceList