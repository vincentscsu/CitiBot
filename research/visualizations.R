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

# visualize simulation data
avail1 = c(0.91, 0.91, 0.83 , 0.83, 0.91,0.91,0.83, 0.71,0.91,0.91, 0.83,0.91,0.91,0.83,0.83,0.83,0.83,0.83,0.91,0.91)
profit1 = c(135, 135, 150, 150, 135, 135, 150,150,135,135,150, 135,135,150,150,150,150,150,135,135)

avail2 = c(0.91, 0.91, 0.83, 0.83, 0.91,0.91,0.83,0.83,0.91,0.91,0.83,0.91,0.91,0.83,0.83,0.83,0.91,0.91,0.83,0.83)
profit2 = c(135, 135, 150, 150, 135, 135, 150, 150, 135,135, 150,135,135,150,150,150,135,135,150,150)

avail3 = c(0.83, 0.74, 0.71, 0.66, 0.71, 0.69, 0.71, 0.66, 0.69, 0.71, 0.69, 0.69, 0.69, 0.74, 0.69, 0.69, 0.77, 0.66,0.69,0.77)
profit3 = c(40, 60, 80, 80, 60, 80, 80, 80, 60, 60, 80, 60, 80, 60, 80, 60, 60,80,60,60)

# plot availability into one graph and profit into another
df1 = as.data.frame(cbind(c(avail1, avail2, avail3)))
names(df1) = "Value"
df1$Objective = c(rep("Maximizing Availability",20), rep("Maximizing Profit", 20), rep("Minimizing Cost", 20))
df1$X = as.factor(rep(1:20,3))
ggplot(df1, aes(x=X, y=Value, col=Objective, group=Objective)) + 
  geom_line() + geom_point() + 
  labs(title = "Availability Comparison", x = "Weeks", y = "Weekly Avg. Availability") +
  ylim(0.6,0.95)

df2 = as.data.frame(cbind(c(profit1, profit2, profit3)))
names(df2) = "Value"
df2$Objective = c(rep("Maximizing Availability",20), rep("Maximizing Profit", 20), rep("Minimizing Cost", 20))
df2$X = as.factor(rep(1:20,3))
ggplot(df2, aes(x=X, y=Value, col=Objective, group=Objective)) + 
  geom_line() + geom_point() + 
  labs(title = "Profit Comparison", x = "Weeks", y = "Weekly Profit ($)") + 
  ylim(0,150)
