# get raw trips data
# train on entire 2015 and test on Jan & Feb in 2016
jan = read.csv('datasets/citibike-2015/201501-citibike-tripdata.csv')
feb = read.csv('datasets/citibike-2015/201502-citibike-tripdata.csv')
mar = read.csv('datasets/citibike-2015/201503-citibike-tripdata.csv')
apr = read.csv('datasets/citibike-2015/201504-citibike-tripdata.csv')
may = read.csv('datasets/citibike-2015/201505-citibike-tripdata.csv')
jun = read.csv('datasets/citibike-2015/201506-citibike-tripdata.csv')
jul = read.csv('datasets/citibike-2015/201507-citibike-tripdata.csv')
aug = read.csv('datasets/citibike-2015/201508-citibike-tripdata.csv')
sep = read.csv('datasets/citibike-2015/201509-citibike-tripdata.csv')
oct = read.csv('datasets/citibike-2015/201510-citibike-tripdata.csv')
nov = read.csv('datasets/citibike-2015/201511-citibike-tripdata.csv')
dec = read.csv('datasets/citibike-2015/201512-citibike-tripdata.csv')

jan16 = read.csv('datasets/citibike-2016/201601-citibike-tripdata.csv')
feb16 = read.csv('datasets/citibike-2016/201602-citibike-tripdata.csv')

# get station data
library(rjson)
stationsJSON = fromJSON(file = 'datasets/stations.json')[2][[1]]
stationNum = length(stationsJSON)
# convert null into NA
stationsJSON = lapply(stationsJSON, function(y) {lapply(unlist(y), function(x) {if (x == '') x = NA else x})})
# convert list of lists to dataframe
stations = data.frame(matrix(unlist(stationsJSON), nrow=stationNum, byrow=T), stringAsFactor=F)
colnames(stations) = c('id', 'stationName', 'availableDocks', 'totalDocks', 'latitude', 'longitude', 'statusValue', 'statusKey', 'availableBikes', 'stAddress1', 'stAddress2', 'postalCode', 'location', 'altitude', 'testStation', 'lastCommunicationTime' ,'landMark')

# cleaning
stations[,18]= NULL
stations[,18]= NULL
stations$testStation = stations$lastCommunicationTime
stations$lastCommunicationTime = stations$landMark
stations$landMark = NA
stations$stAddress2 = NA
stations$postalCode = NA
stations$location = NA
stations$altitude = NA
head(stations)

stations$totalDocks = as.numeric(as.character(stations$totalDocks))
stations$stationName = as.character(stations$stationName)

# get weather data
janWeather = read.table('datasets/weather/2015/janWeather.csv', header = T)
febWeather = read.table('datasets/weather/2015/janWeather.csv', header = T)
marWeather = read.table('datasets/weather/2015/janWeather.csv', header = T)
aprWeather = read.table('datasets/weather/2015/janWeather.csv', header = T)
mayWeather = read.table('datasets/weather/2015/janWeather.csv', header = T)
junWeather = read.table('datasets/weather/2015/janWeather.csv', header = T)
julWeather = read.table('datasets/weather/2015/janWeather.csv', header = T)
augWeather = read.table('datasets/weather/2015/janWeather.csv', header = T)
sepWeather = read.table('datasets/weather/2015/janWeather.csv', header = T)
octWeather = read.table('datasets/weather/2015/janWeather.csv', header = T)
novWeather = read.table('datasets/weather/2015/janWeather.csv', header = T)
decWeather = read.table('datasets/weather/2015/janWeather.csv', header = T)

jan16Weather = read.table('datasets/weather/2016/janWeather.csv', header = T)
feb16Weather = read.table('datasets/weather/2016/febWeather.csv', header = T)

######################### Data transformation to include other information ##############################
janNew = transformMonth(jan, janWeather)
febNew = transformMonth(feb, febWeather)
marNew = transformMonth(mar, marWeather)
aprNew = transformMonth(apr, aprWeather)
mayNew = transformMonth(may, mayWeather)
junNew = transformMonth(jun, junWeather)
julNew = transformMonth(jul, julWeather)
augNew = transformMonth(aug, augWeather)
sepNew = transformMonth(sep, sepWeather)
octNew = transformMonth(oct, octWeather)
novNew = transformMonth(nov, novWeather)
decNew = transformMonth(dec, decWeather)

jan16New = transformMonth(jan16, jan16Weather)
feb16New = transformMonth(feb16, feb16Weather)

# add national holidays
janNew[janNew$day == '1',]$holiday =  '1'
janNew[janNew$day == '19',]$holiday =  '1'
febNew[febNew$day == '16',]$holiday =  '1'
mayNew[mayNew$day == '25',]$holiday =  '1'
julNew[julNew$day == '3',]$holiday =  '1'
sepNew[sepNew$day == '7',]$holiday =  '1'
novNew[novNew$day == '26',]$holiday =  '1'
decNew[decNew$day == '25',]$holiday =  '1'

jan16New[jan16New$day == '1',]$holiday =  '1'
jan16New[jan16New$day == '18',]$holiday =  '1'
feb16New[feb16New$day == '15',]$holiday =  '1'

# train on entire 2015
train = rbind(janNew, febNew, marNew, aprNew, mayNew, junNew, julNew, augNew, sepNew, octNew, novNew, decNew)
head(train)
write.csv(train, 'train.csv')

# test on Jan & Feb in 2016 
test = rbind(jan16New, feb16New)
# remove new stations not in training set
test = test[test$stationID %in% unique(train$stationID),]
head(test)
write.csv(test, 'test.csv')

######################### Model to Predict daily demand ##############################
library(Metrics) # RMSLE - penalize under-predicted more than over prediction

# baseline RMSE
sqrt(mean((mean(train$visited) - test$visited)^2))

# regression tree

rpartModel = rpart(visited ~ dayOfWeek + holiday + season + stationID + max + min + rain + snow, data=train, method = 'anova')
summary(rpartModel)

pred = predict(rpartModel, newdata=test)
rmsle(test$visited, pred)
sqrt(mean((test$visited - pred)^2))

# random forest regression
# library(randomForest)
# make sure train/test levels are the same
# rfModel = randomForest(visited ~ dayOfWeek + hour + longitude, data=train)
# predRf = predict(rfModel, newdata=test)
# rmsle(test$visited, predRf)
# RF cannot handle more than 54 levels

# gradient boosted model (GBM)
# library(gbm)
# gbmModel = gbm(visited ~ dayOfWeek + holiday + season + stationID + max + min + rain + snow, data=train, distribution= "gaussian ",n.trees=100, interaction.depth=3)
# summary(gbmModel)
# 
# plot(gbmModel, i='dayOfWeek')
# 
# predGbm = predict(gbmModel, newdata=test, n.trees = 100)
# rmsle(test$visited, predGbm)
# mean((test$visited - predGbm)^2)

# predict demand for single station by day

# get average RMSLE for all stations in testset
library(scales)
numStationsTest = length(unique(test$stationID))
pred = c(0, 0)
count = 1
for (i in unique(test$stationID)) {
  print(percent(count/numStationsTest))
  trainSingle = train[train$stationID == i,]
  testSingle = test[test$stationID == i,]
  
  levels(testSingle$dayOfWeek) = levels(trainSingle$dayOfWeek)
  levels(testSingle$holiday) = levels(trainSingle$holiday)
  levels(testSingle$season) = levels(trainSingle$season)
  
  rfModel = randomForest(visited ~ dayOfWeek + holiday + season + max + min + rain + snow, data=trainSingle)
  rpart(visited ~ dayOfWeek + holiday + season + max + min + rain + snow, data=trainSingle, method = 'anova')
  # gbmModel = gbm(visited ~ dayOfWeek + holiday + season + max + min + rain + snow, data=trainSingle, distribution = 'gaussian', n.trees = 1000, interaction.depth = 1)
  
  predRf = predict(rfModel, newdata = testSingle)
  predRpart = predict(rpartModel, newdata = testSingle)
  # predGbm = predict(gbmModel, newdata = testSingle, n.trees=2000)  
  
  rmsleRf = rmsle(testSingle$visited, predRf)
  rmsleRpart = rmsle(testSingle$visited, predRpart)
  # rmsleGbm = rmsle(testSingle$visited, predGbm)
  
  pred = pred + c(rmsleRf, rmsleRpart) #, rmsleGbm)
  count = count + 1
}

pred = pred / numStationsTest
pred

# random forest wins