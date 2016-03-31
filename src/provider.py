class Provider: 
	""" A service provider for bike stations.

	Attributes:
		id: provider id
		inventory: available units
		profit: money earned through servicing stations
		priceList: service level and their prices - level 1 takes 3 days, level 2 takes 2 days, level 3 takes 1 day
	"""

	def __init__(self, id=1, inventory=2, profit=0, priceList={1:10, 2:15, 3:25}):
		self.id = id
		self.inventory = inventory
		self.profit = profit
		self.priceList = priceList