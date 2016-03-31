library(ggplot2)

avgDayVisits = data.frame('dayOfWeek' = c('Monday','Tuesday', 'Wednesday', 'Thursday','Friday','Saturday','Sunday'),
                'visits' = c(mean(train[train$dayOfWeek == 'Monday',]$visited),
                             mean(train[train$dayOfWeek == 'Tuesday',]$visited),
                             mean(train[train$dayOfWeek == 'Wednesday',]$visited),
                             mean(train[train$dayOfWeek == 'Thursday',]$visited),
                             mean(train[train$dayOfWeek == 'Friday',]$visited),
                             mean(train[train$dayOfWeek == 'Saturday',]$visited),
                             mean(train[train$dayOfWeek == 'Sunday',]$visited)))
avgDayVisits

ggplot(avgDayVisits, aes(dayOfWeek, visits)) + geom_bar(stat = 'identity') + labs(title='Avg. Number of Visits in a Week (2015)', x='Day of Week', y='Visits')

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

ggplot(monthVisits, aes(as.factor(month), visits)) + geom_bar(stat = 'identity') + labs(title='Number of Visits per Month (2015)', x='Month', y='Visits')

highVisits = data.frame(data.table(train[,c('max','visited')])[, list(visits = mean(visited)), by=max])
lowVisits = data.frame(data.table(train[,c('min','visited')])[, list(visits = mean(visited)), by=min])

tempVisits = rbind(data.frame('temp' = highVisits$max, 'visits' = highVisits$visits, 'type'='high'),
                   data.frame('temp' = lowVisits$min, 'visits' = lowVisits$visits, 'type'='low'))

ggplot(data=tempVisits, aes(x=temp, y=visits, group=type, colour=type)) + geom_line() + geom_point() + labs(title='Number of Visits Based on Daily High/Low Temperature', x='Temperature (F)', y='Visis')

avgTempVisits = data.frame(avgTemp = ((train$max + train$min) / 2), visits = train$visited)
avgTempVisits = data.frame(data.table(avgTempVisits)[, list(visits = mean(visits)), by=avgTemp])

ggplot(data=avgTempVisits, aes(x=avgTemp, y=visits)) + geom_line() + geom_point() + labs(title='Number of Visits Based on Daily Avg. Temperature', x='Temperature (F)', y='Visis')

rainVisits = data.frame(data.table(train[,c('rain','visited')])[, list(visits = mean(visited)), by=rain])
ggplot(data=rainVisits, aes(x=rain, y=visits)) + geom_line() + geom_point() + labs(title='Number of Visits Based on Daily Rain', x='Rain (in)', y='Visis')

snowVisits = data.frame(data.table(train[,c('snow','visited')])[, list(visits = mean(visited)), by=snow])
ggplot(data=snowVisits, aes(x=snow, y=visits)) + geom_line() + geom_point() + labs(title='Number of Visits Based on Daily Snow', x='Snow (in)', y='Visis')

