library(ggplot2)
library(ggvis)
avgDayVisits = data.frame('dayOfWeek' = c('Monday','Tuesday', 'Wednesday', 'Thursday','Friday','Saturday','Sunday'),
                'visits' = c(mean(train[train$dayOfWeek == 'Monday',]$visited),
                             mean(train[train$dayOfWeek == 'Tuesday',]$visited),
                             mean(train[train$dayOfWeek == 'Wednesday',]$visited),
                             mean(train[train$dayOfWeek == 'Thursday',]$visited),
                             mean(train[train$dayOfWeek == 'Friday',]$visited),
                             mean(train[train$dayOfWeek == 'Saturday',]$visited),
                             mean(train[train$dayOfWeek == 'Sunday',]$visited)))
avgDayVisits
# reorder levels
avgDayVisits$dayOfWeek = factor(avgDayVisits$dayOfWeek, levels(avgDayVisits$dayOfWeek)[c(2,6,7,5,1,3,4)])
ggplot(avgDayVisits, aes(dayOfWeek, visits)) + geom_bar(stat = 'identity') + labs(title='Avg. Number of Visits in a Week (2015)', x='Day of Week', y='Avg. Visits')

avgDayVisits %>% ggvis(~dayOfWeek, ~visits) %>% layer_bars()

monthVisits = data.frame('month' = c(1,2,3,4,5,6,7,8,9,10,11,12), 
                         'visits' = c(sum(train[train$month == 1,]$visited),
                                      sum(train[train$month == 2,]$visited),
                                      sum(train[train$month == 3,]$visited),
                                      sum(train[train$month == 4,]$visited),
                                      sum(train[train$month == 5,]$visited),
                                      sum(train[train$month == 6,]$visited),
                                      sum(train[train$month == 7,]$visited),
                                      sum(train[train$month == 8,]$visited),
                                      sum(train[train$month == 9,]$visited),
                                      sum(train[train$month == 10,]$visited),
                                      sum(train[train$month == 11,]$visited),
                                      sum(train[train$month == 12,]$visited)))

monthVisits

ggplot(monthVisits, aes(as.factor(month), visits/1000000)) + geom_bar(stat = 'identity') + labs(title='Total Number of Visits per Month (2015)', x='Month', y='Visits (millions)')

highVisits = data.frame(data.table(train[,c('max','visited')])[, list(visits = mean(visited)), by=max])
lowVisits = data.frame(data.table(train[,c('min','visited')])[, list(visits = mean(visited)), by=min])

tempVisits = rbind(data.frame('temp' = highVisits$max, 'visits' = highVisits$visits, 'type'='high'),
                   data.frame('temp' = lowVisits$min, 'visits' = lowVisits$visits, 'type'='low'))

ggplot(data=tempVisits, aes(x=temp, y=visits, group=type, colour=type)) + geom_line() + geom_point() + labs(title='Number of Visits Based on Daily High/Low Temperature', x='Temperature (F)', y='Visis')

avgTempVisits = data.frame(avgTemp = ((train$max + train$min) / 2), visits = train$visited)
avgTempVisits = data.frame(data.table(avgTempVisits)[, list(visits = mean(visits)), by=avgTemp])

ggplot(data=avgTempVisits, aes(x=avgTemp, y=visits)) + geom_smooth() + geom_point() + labs(title='Number of Visits Based on Daily Avg. Temperature', x='Temperature (F)', y='Visis')

rainVisits = data.frame(data.table(train[,c('rain','visited')])[, list(visits = mean(visited)), by=rain])
ggplot(data=rainVisits, aes(x=rain, y=visits, color = rain, size = 13)) + geom_point() + labs(title='Number of Visits Based on Daily Rain', x='Rain (in)', y='Visis') + scale_size(guide="none")

snowVisits = data.frame(data.table(train[,c('snow','visited')])[, list(visits = mean(visited)), by=snow])
ggplot(data=snowVisits, aes(x=snow, y=visits)) + geom_smooth(se=F, size=1.5) + labs(title='Number of Visits Based on Daily Snow', x='Snow (in)', y='Visis')
snowVisits %>% ggvis(~snow, ~visits, stroke:='blue') %>% layer_smooths()

# visualize station sum of checkins in 2015
raw2015 = rbind(jan,feb,mar,apr,may,jun,jul,aug,sep,oct,nov,dec)
yearlyVisits = cbind(raw2015[,c('start.station.latitude','start.station.longitude', 'end.station.latitude', 'end.station.longitude')])
startVisits = yearlyVisits[,c(1,2)]
endVisits = yearlyVisits[,c(3,4)]
names(startVisits) = c('lat', 'lon')
names(endVisits) = c('lat', 'lon')
yearlyVisits = rbind(startVisits, endVisits)
yearlyVisits$visits = 1
yearlyVisits = data.table(yearlyVisits)[, list(visits = sum(visits)), by='lat,lon']
head(yearlyVisits)
write.csv(yearlyVisits, 'yearlyCarto.csv', row.names = F)

startVisits$visits = 1
startVisits = data.table(startVisits)[, list(visits = sum(visits)), by='lat,lon']
write.csv(startVisits, 'yearlyCarto-start.csv', row.names = F)

endVisits$visits = 1
endVisits = data.table(endVisits)[, list(visits = sum(visits)), by='lat,lon']
write.csv(endVisits, 'yearlyCarto-end.csv', row.names = F)
