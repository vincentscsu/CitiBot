class Provider: 
	""" A service provider for bike stations.

	Attributes:
		inventory: available units
		profit: money earned through servicing stations
		levelList: service level and tuple of their respective price and duration - level 1 takes 3 days, level 2 takes 2 days, level 3 takes 1 day
	"""
	_inventory = 3
	_profit = 0
	_levelList = {1:(20,3), 2:(30,2), 3:(45,1)}