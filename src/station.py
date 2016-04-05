from provider import Provider

class Station:
	""" A Citi Bike station that needs maintenace service regularly as usage accumulates.

	Attributes:
		budget: repair budget for the entire city
		numOperating: at any given time the minimum number of stations operating cannot fall below this value
		id: station id
		name:
		latitude: 
		longitude:
		inService: whether the station is in service or not
		usage: count of visits accumulated from last service
	"""
	_budget = 10000
	_numOperating = 3

	provider = Provider()
	stationDict = {	387: 1, 
					521: 2,
					293: 3,
					127: 4,
					83:  5 }

	def __init__(self, id, name="", latitude=0, longitude=0, inService=1, usage=0, maxUsage=1000):
		self.id = id
		self.name = name
		self.latitude = latitude
		self.longitude = longitude
		self.inService = inService
		self.usage = usage
		self.maxUsage = maxUsage

	def visit(self, num):
		"""One bike checkout or return (one visit at the station)
		   If usage is greated than maximum allowed usage, then change status to not in service
		   A station cannot be accessed when it's not in service

		   When usage is greater than half of maximum usage, request service
		"""
		if self.inService == 0:
			return
		
		self.usage += num

		if self.usage > self.maxUsage:
			self.inService = 0

		if self.usage > self.maxUsage/2:
			# TODO: choose which level is best
			level = 1
			self.requestService(Station.provider, level)

	def requestService(self, provider, level):
		if Provider._inventory == 0:
			print('Provider has no available units.')
		else:
			print('*Requesting service level', level, 'for station', Station.stationDict[self.id])
			Provider._inventory -= 1
			price = provider.priceList[level]
			Provider._profit += price
			Station._budget -= price
			self.inService = 0
			