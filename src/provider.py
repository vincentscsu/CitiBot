class Provider: 
	""" A service provider for bike stations.

	Attributes:
		inventory: available units
		profit: money earned through servicing stations
		levelList: service level and tuple of their respective price and duration - level 1 takes 3 days, level 2 takes 2 days, level 3 takes 1 day
	"""
	_inventory = 2
	_profit = 0
	_levelList = {1:(10,3), 2:(15,2), 3:(25,1)}