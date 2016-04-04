from station import Station
from provider import Provider
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
	models = joblib.load("research/models/singleGBMs.pkl")

	today = 7 # initialize as Sunday

	while True:
		print('############################################################################')
		print('Current usage:')
		print('----------------------------')
		print('Station 1 usage:', s1.usage)
		print('Station 2 usage:', s2.usage)
		print('Station 3 usage:', s3.usage)
		print('Station 4 usage:', s4.usage)
		print('Station 5 usage:', s5.usage)

		print('\nToday\'s information:')
		print('----------------------------')
		
		# get day of week
		print('Day of Week: ', getDayOfWeek(today))
		if today + 1 > 7:
			today = 1
		else:
			today += 1

		# get today's weather features
		high, low, rain, snow = getWeather()
		print('High Temp.:', high)
		print('Low Temp.:', low)
		print('Rain:', rain)
		print('Snow:', snow)

		# predict demand of each station using its own model
		features = []
		demands = []
		indices = range(len(stations))
		for station, index in zip(stations, indices):
			features.append(genFeature(today, station.id, high, low, rain, snow))
			pred = models[index].predict(features[-1])
			if pred < 0:
				demands.append(0)
			else:
				demands.append(int(pred[0]))

		print('Demand of each station: ', demands)

		print('Randomly visit a bike station...')
		random.choice(stations).visit()

		input("Press Enter to continue...\n")

def getDayOfWeek(today):
	"""Get next day of week"""
	days = {1:'Monday',
	        2:'Tueday',
	        3:'Wednesday',
	        4:'Thursday',
	        5:'Friday',
	        6:'Saturday',
	        7:'Sunday'}

	return days[today]

def getWeather():
	maxTemp = random.uniform(20,30)
	minTemp = maxTemp - random.uniform(5,10)
	rain = 0
	snow = random.uniform(0,2)

	return [maxTemp, minTemp, rain, snow]

def genFeature(today, stationID, high, low, rain, snow):
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

	featureVec[today] = 1
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