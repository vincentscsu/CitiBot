from provider import Provider

class Station:
	""" A Citi Bike station that needs maintenace service regularly as usage accumulates.

	Attributes:
		budget: weekly budget for all the stations
		score: weekly avg availability
		id: station id
		name:
		latitude: 
		longitude:
		inService: whether the station is in service or not
		usage: count of visits accumulated from last service
	"""
	_budget = 100
	_budgetLeft = _budget
	_score = 0

	stationDict = {	387: 1, 
					521: 2,
					293: 3,
					127: 4,
					83:  5 }

	def __init__(self, id, name="", latitude=0, longitude=0, inService=1, pendingDays=0, waiting=0, usage=0, maxUsage=100):
		self.id = id
		self.name = name
		self.latitude = latitude
		self.longitude = longitude
		self.inService = inService
		self.pendingDays = pendingDays
		self.waiting = waiting
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

		# if self.usage > self.maxUsage:
		# 	self.inService = 0

		# # request service when usage is above half of max
		# if self.usage > self.maxUsage/2:
		# 	self.requestService()

	def requestService(self):
		"""request service when usage > 1/2 of maximum usage"""
		# select the best level service
		level = self.selectLevel()
		if level == -1:
			print("Not enough budget to request any service..")
			return
		print('Requesting service level', level, 'for station', Station.stationDict[self.id])

		if Provider._inventory == 1:
			# provider must have 1 available at all times for emergency
			# if no availability, try again next day and keep trying until available
			self.waiting = 1
			print('Provider has no available units. Try again tomorrow.')
		else:
			print('Successfully requested service level', level, 'for station', Station.stationDict[self.id])
			self.waiting = 0
			Provider._inventory -= 1
			price = Provider._levelList[level][0]
			days = Provider._levelList[level][1]
			Provider._profit += price
			Station._budgetLeft -= price
			# station being serviced is put out of operation
			self.inService = 0
			self.pendingDays = days
	
	def selectLevel(self):
		"""select the best level to request to maximize station availability (and provider profit?)"""
		# TODO
		# greedy approach: always choose level 3 first
		price1 = Provider._levelList[1][0]
		price2 = Provider._levelList[2][0]
		price3 = Provider._levelList[3][0]

		if Station._budgetLeft > price3:
			return 3
		elif Station._budgetLeft > price2:
			return 2
		elif Station._budgetLeft > price1:
			return 1
		else: 
			return -1