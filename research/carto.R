######################### Data transformation for CartoDB ##############################
library(plyr)
transform = function(month) {
  # transfrom dataset for CartoDB (stations)
  # date stationID, longitude, latitude, check-in
  rentBike = month[c('starttime', 'start.station.id', 'start.station.longitude', 'start.station.latitude')]
  names(rentBike) = c('date', 'stationID', 'longitude', 'latitude')
  returnBike = month[c('stoptime', 'end.station.id', 'end.station.longitude', 'end.station.latitude')]
  names(returnBike) = c('date', 'stationID', 'longitude', 'latitude')  
  monthCarto = cbind(rbind(rentBike, returnBike), checkin=1)
  
  # adding up all checkins at the same location in the same time
  ddply(monthCarto, .(date, stationID, longitude, latitude), summarize, checkin = sum(checkin))
}

febCartoCombined = transform(feb)
augCartoCombined = transform(aug[1:200000,])

head(augCartoCombined)
tail(augCartoCombined)

head(febCartoCombined)
tail(febCartoCombined)

write.csv(febCartoCombined, file='febCartoCombined.csv')
write.csv(augCartoCombined, file='augCartoCombined.csv')

transformTwo = function(month) {
  # transfrom dataset for CartoDB (stations)
  # date stationID, longitude, latitude, in(0)/out(1)
  rentBike = cbind(month[c('starttime', 'start.station.id', 'start.station.longitude', 'start.station.latitude')], 0)
  names(rentBike) = c('date', 'stationID', 'longitude', 'latitude', 'checkin-out')
  returnBike = cbind(month[c('stoptime', 'end.station.id', 'end.station.longitude', 'end.station.latitude')], 1)
  names(returnBike) = c('date', 'stationID', 'longitude', 'latitude', 'checkin-out')  
  monthCarto = rbind(rentBike, returnBike)
}

febCartoCombinedTwo = transformTwo(feb)
head(febCartoCombinedTwo)
tail(febCartoCombinedTwo)
table(febCartoCombinedTwo$`checkin-out`)
write.csv(febCartoCombinedTwo, file='febCartoCombinedTwo.csv')
