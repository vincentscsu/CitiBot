from station import Station
from provider import Provider
from collections import deque
from sklearn.externals import joblib
import pandas as pd
import random

def main():
	# using real station id from training set - stations with far apart number of visits
	s1 = Station(387)
	s2 = Station(521)
	s3 = Station(293)
	s4 = Station(127)
	s5 = Station(83)

	stations = [s1, s2, s3, s4, s5]
	provider = Provider()

	models = joblib.load("research/models/singleGBMs.pkl")

	tomorrow = 1 # initialize as Monday
	print('############################################################################')
	print('                       Start On-demand Marketplace!')
	print('############################################################################')
	print('Current usage:')
	print('------------------------------------')
	print('Station 1:', s1.usage)
	print('Station 2:', s2.usage)
	print('Station 3:', s3.usage)
	print('Station 4:', s4.usage)
	print('Station 5:', s5.usage)

	print('\nCiti Bike Info:')
	print('------------------------------------')
	print('Available Budget:', Station._budget)
	percentage = sum([s.inService for s in stations]) / len(stations)
	print('% stations in service:', "{0:.0%}".format(percentage))

	print('\nProvider Info:')
	print('------------------------------------')
	print('Available Inventory:', Provider._inventory)
	print('Profit:', Provider._profit)

	print('\nDemand prediction for next 7 days:')
	print('------------------------------------')
	
	# predict station demand for the next 7 days at each station using its own pre-trained model
	demandsNext = deque() # use queue to update rolling demands

	for day in range(1,8):
		features = []
		demands = []
		indices = range(len(stations))

		# generate this day's weather forecast
		high, low, rain, snow = genWeather()
		
		# predict demand for each station for the next day
		for station, index in zip(stations, indices):
			# generate feature vector for prediction model
			features.append(genFeature(day, station.id, high, low, rain, snow))
			pred = models[index].predict(features[-1])
			if pred < 0:
				demands.append(0)
			else:
				demands.append(int(pred[0]))
		
		demandsNext.append(demands)

	print(demandsNext)
	input("\nPress Enter to continue...\n")
	# next day to predict is Monday
	nextDay = 1

	while True:

		# generate station visits for the day
		actualVisits = []
		for station, demand in zip(stations, demands):
			if station.inService == 0:
				# cannot visit the station if it's not in operation
				actualVisits.append(0)
			else:
				actualVisit = int(max(random.uniform(demand*0.8,demand*1.2), 0))
				station.visit(actualVisit)
				actualVisits.append(actualVisit)
		
		print('############################################################################')
		print('Current station usage:')
		print('------------------------------------')
		print('Station 1:', s1.usage)
		print('Station 2:', s2.usage)
		print('Station 3:', s3.usage)
		print('Station 4:', s4.usage)
		print('Station 5:', s5.usage)

		print('\nCiti Bike Info:')
		print('------------------------------------')
		print('Available Budget:', station._budget)
		percentage = sum([s.inService for s in stations]) / len(stations)
		print('% stations in service:', "{:.0%}".format(percentage))
		Station._score += percentage

		# update day of week and reset when beyond Sunday
		nextDay += 1
		if nextDay == 8:
			nextDay = 1
			Station._budget = 1000 # renew weekly budget

			# print objective: avg availability for the past week
			avgScore = Station._score / 7
			print('Station 7-day average availability:', "{:.0%}".format(avgScore))
			Station._score = 0

		print('\nProvider Info:')
		print('------------------------------------')
		print('Available Inventory:', Provider._inventory)
		print('Profit:', Provider._profit)	

		# get next day's weather features
		high, low, rain, snow = genWeather()

		# predict demand for each station for the next day		
		features = []
		demands = []
		currentUsage = [] # create a current usage list to compare with future demand and decide service level
		for station, index in zip(stations, indices):
			# create current usage list
			currentUsage.append(station.usage)

			# generate feature vector for prediction model
			features.append(genFeature(nextDay, station.id, high, low, rain, snow))
			pred = models[index].predict(features[-1])
			if pred < 0:
				demands.append(0)
			else:
				demands.append(int(pred[0]))
		# get rid of prediction in the past and add a new one in the rolling prediction
		demandsNext.popleft()
		demandsNext.append(demands)

		print('\nDemand prediction for next 7 days:')
		print('------------------------------------')
		print(demandsNext)

		print('\nActual visits of each station today: ')
		print(actualVisits)
		
		# check service request status	
		print("\nStation Maintenance Info:")
		print("------------------------------------")	
		for station in stations:
			if station.waiting:
				# try again if provider's inventory was full yesterday
				station.requestService()
			elif station.inService == 0:
				if station.pendingDays != 0: # being serviced, check days left
					print("Station", Station.stationDict[station.id], "being serviced:", station.pendingDays, "days left.")
					station.pendingDays -= 1
				else: # back to operation
					station.usage = 0
					station.inService = 1
					Provider._inventory += 1
					print("Station", Station.stationDict[station.id], "back in operation tomorrow.")
			elif station.usage > station.maxUsage: # over used, suspend
				station.inService = 0
			elif station.usage > station.maxUsage / 2: # start requesting maintenance when usage greater than half of max
				# request service when usage is above half of max
				station.requestService()

		input("\nPress Enter to continue...\n")

def getDayOfWeek(tomorrow):
	"""Get next day of week"""
	days = {1:'Monday',
	        2:'Tueday',
	        3:'Wednesday',
	        4:'Thursday',
	        5:'Friday',
	        6:'Saturday',
	        7:'Sunday'}

	return days[tomorrow]

def genWeather():
	"""generate weather data for one winter day"""
	maxTemp = random.uniform(20,30)
	minTemp = maxTemp - random.uniform(5,10)
	rain = 0
	snow = random.uniform(0,2)

	return [maxTemp, minTemp, rain, snow]

def genFeature(tomorrow, stationID, high, low, rain, snow):
	"""Generate 1 sample feature vector for demand prediction."""
	featureVec = pd.Series({'Monday':0,
		'Tueday':0,
		'Wednesday':0,
		'Thursday':0,
	    'Friday':0,
	    'Saturday':0,
	    'Sunday':0,
	    'holiday':0,
	    'winter':0,
	    'stationID':0,
	    'max':0,
	    'min':0,
	    'rain':0,
	    'snow':0})

	featureVec[tomorrow] = 1
	featureVec['stationID'] = stationID
	featureVec['winter'] = 1 # assume it's winter now - model only has winter as season because original test set uses 2016 data (Jan & Feb) 
	featureVec['max'] = high
	featureVec['min'] = low
	featureVec['rain'] = rain
	featureVec['snow'] = snow

	# reshape because 1D array only contains one sample
	return featureVec.reshape(1,-1)

if __name__ == '__main__':
	main()
