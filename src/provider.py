class Provider: 
	""" A service provider for bike stations.

	Attributes:
		id: provider id
		inventory: available units
		profit: money earned through servicing stations
	"""

	def __init__(self, id, inventory=100, profit=0):
		self.id = id
		self.inventory = inventory
		self.profit = profit