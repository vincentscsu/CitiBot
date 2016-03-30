library(data.table)
library(lubridate)

transformMonth = function(month, weather) {
  # combine monthly Citi Bike data and weather data and extract useful features
  
  # separating checkouts and returns and remove redundant features
  monthSeparated = rbind(data.frame('date' = month$starttime, 'stationID' = month$start.station.id, 'visited' = 1),
                         data.frame('date' = month$stoptime, 'stationID' = month$end.station.id, 'visited' = 1))
  
  # parsing date information
  monthSeparated$date = strptime(monthSeparated$date, format = "%m/%d/%Y %H:%M", tz="EST")
  monthSeparated$month = month(monthSeparated$date)
  monthSeparated$day = day(monthSeparated$date)
  monthSeparated$dayOfWeek = weekdays(monthSeparated$date)

  # aggregate visits
  names = 'month,day,dayOfWeek,stationID'
  tmpTable = data.table(monthSeparated)
  monthSeparated = as.data.frame(tmpTable[, list(visited = sum(visited)), by=names])
  
  # add working day or holiday to dataframe
  monthSeparated$holiday = '0'
  monthSeparated[monthSeparated$dayOfWeek %in% c('Saturday', 'Sunday'),]$holiday = '1'
  
  # combine with weather data
  monthHourWeather = merge(monthSeparated, weather, by=c('day'))
  monthHourWeather$month = monthHourWeather$month.x
  monthHourWeather$month.x = NULL
  monthHourWeather$month.y = NULL

  # add season
  month = names(sort(table(monthHourWeather$month), decreasing = T)[1])
  if (month %in% c('12', '1', '2')) monthHourWeather$season = 'winter' else
  if (month %in% c('3', '4', '5')) monthHourWeather$season = 'spring' else
  if (month %in% c('6', '7', '8')) monthHourWeather$season = 'summer' else
  if (month %in% c('9', '10', '11')) monthHourWeather$season = 'fall'

  # convert attribute types
  monthHourWeather = convert(monthHourWeather)
    
  # reorder columns
  monthHourWeather = monthHourWeather[,c('month', 'day', 'dayOfWeek', 'holiday', 'season', 'stationID', 'max', 'min', 'rain', 'snow', 'visited')]  
  monthHourWeather
}

convert = function(data) {
  # convert attributes
  data$month = as.character(data$month)
  data$day = as.character(data$day)
  data$dayOfWeek = as.factor(data$dayOfWeek)
  data$holiday = as.factor(data$holiday)
  data$season = as.factor(data$season)
  data$stationID = as.factor(data$stationID)
  data
}

findPopularStations = function(month, num = 5) {
  # find top # most popular renting and returning stations
  popularStart = ddply(data.frame('stationID' = month$start.station.id, 'stationName' = month$start.station.name, 'count' = 1), .(stationID, stationName), summarize, count = sum(count))
  start = head(popularStart[order(-popularStart$count),], num)
  
  popularEnd = ddply(data.frame('stationID' = month$end.station.id, 'stationName' = month$end.station.name, 'count' = 1), .(stationID, stationName), summarize, count = sum(count))
  end = head(popularEnd[order(-popularEnd$count),], num)
  list(start, end)
}