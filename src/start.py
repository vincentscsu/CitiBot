from station import Station
from provider import Provider
import random

def main():
	s1 = Station(1)
	s2 = Station(2)
	s3 = Station(3)
	s4 = Station(4)
	s5 = Station(5)

	stations = [s1, s2, s3, s4, s5]

	while True:
		print('Current usage:')
		print('######################################')
		print('Station 1 usage:', s1.usage)
		print('Station 2 usage:', s2.usage)
		print('Station 3 usage:', s3.usage)
		print('Station 4 usage:', s4.usage)
		print('Station 5 usage:', s5.usage)
		print('######################################\n')
		print('Randomly visit a bike station...')
		random.choice(stations).visit()

		input("Press Enter to continue...\n")

if __name__ == '__main__':
	main()