######################### EDA ##############################
library(ggplot2)

head(feb)
head(aug)
head(stations)

nrow(feb)
nrow(apr)
nrow(aug)
nrow(sep)
nrow(oct)
# summer/fall have much more trips -> due to expansion?

findPopularStations(feb)
findPopularStations(aug)
# popular stations differ

table(apply(feb, 1, function(x) strsplit(strsplit(as.character(x['starttime']), split=' ')[[1]][1], split='/')[[1]][1] != '2'))
table(apply(feb, 1, function(x) strsplit(strsplit(as.character(x['stoptime']), split=' ')[[1]][1], split='/')[[1]][1] != '2'))
subset(feb, apply(feb, 1, function(x) strsplit(strsplit(as.character(x['stoptime']), split=' ')[[1]][1], split='/')[[1]][1] != '2'))
# exist people who rent a bike last day in Feb and return in March

# weather
head(weatherFeb)
head(weatherAug)

# station info

sum(stations$totalDocks)/stationNum
# total number of docks is 16,578, is that the number of bikes available???
# on average one station has 33 docks

# most start trip station
sort(table(feb$start.station.id), decreasing = T)[1]
sort(table(apr$start.station.id), decreasing = T)[1]
sort(table(aug$start.station.id), decreasing = T)[1]
sort(table(sep$start.station.id), decreasing = T)[1]
sort(table(oct$start.station.id), decreasing = T)[1]

# seems like id 521 is most popular to start off
sort(table(jan$end.station.id), decreasing = T)[1]
sort(table(feb$end.station.id), decreasing = T)[1]
sort(table(apr$end.station.id), decreasing = T)[1]
sort(table(aug$end.station.id), decreasing = T)[1]
sort(table(sep$end.station.id), decreasing = T)[1]
sort(table(oct$end.station.id), decreasing = T)[1]

# and 293/521 most popular for returning 
# use 521 to experiment
stations[stations$id == '521',]$stationName
