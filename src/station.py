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
	_numOperating = 400

	def __init__(self, id, name="", latitude=0, longitude=0, inService=1, usage=0, maxUsage=1000):
		self.id = id
		self.name = name
		self.latitude = latitude
		self.longitude = longitude
		self.inService = inService
		self.usage = usage
		self.maxUsage = maxUsage

	def visited(self):
		"""One bike checkout or return"""
		self.usage += 1
		if self.usage > self.maxUsage:
			self.inService = 0

	def requestService(self, provider):
		if provider.inventory == 0:
			print('False')
		else:
			provider.inventory -= 1
			self.inService = 0
			# service type here