pragma Singleton
import VPlay 2.0
import QtQuick 2.7

Item {
    id: dataModel

    property bool weatherAvailable: false

    property var weatherData: ({})

    property var forecastData: []

    signal plotData(var time, var min, var max)

    function clearData()  {//TODO
        // Reset all data stored in the model and the cache
//        setModelData1(false, "", undefined, undefined, "", "", false)
    }

    function updateWeatherFromJson(parsedWeatherJson) {
        dataModel.weatherData = {
            'weatherForCity': parsedWeatherJson.name + ", " + parsedWeatherJson.sys.country,
            'weatherTemp': parsedWeatherJson.main.temp,
            'minWeatherTemp': parsedWeatherJson.main.temp_min,
            'maxWeatherTemp': parsedWeatherJson.main.temp_max,
            'weatherCondition': parsedWeatherJson.weather[0].main,
            'weatherIconUrl': "http://openweathermap.org/img/w/" + parsedWeatherJson.weather[0].icon + ".png"
        }
    }

    function formatUTC(utc) {
        var date = new Date(utc);
        // Hours part from the timestamp
        var hours = date.getHours();
        // Minutes part from the timestamp
        var minutes = "0" + date.getMinutes();

        // Will display time in 30:23 format
        var result = Number(hours).toString() + ':' + Number(minutes.substr(-2)).toString();
        return result
    }

    function updateForecastFromJson(parsedWeatherForcast) {
        var index = 0
        for(;index < 5; ++index) {
            var temp = {
                'temp_min': parsedWeatherForcast.list[index].main.temp_min,
                'temp_max': parsedWeatherForcast.list[index].main.temp_max,
                'weatherIconUrl': "http://openweathermap.org/img/w/" + parsedWeatherForcast.list[index].weather[0].icon + ".png",
                'weatherCondition': parsedWeatherForcast.list[index].weather[0].main,
                'time': formatUTC(parsedWeatherForcast.list[index].dt*1000)
            }

            dataModel.forecastData.push(temp)
        }

        //provide data for plot
        var time = []
        var min = []
        var max = []
        time.push(forecastData[0].time)
        time.push(forecastData[1].time)
        time.push(forecastData[2].time)
        time.push(forecastData[3].time)
        time.push(forecastData[4].time)
        min.push(forecastData[0].temp_min)
        min.push(forecastData[1].temp_min)
        min.push(forecastData[2].temp_min)
        min.push(forecastData[3].temp_min)
        min.push(forecastData[4].temp_min)
        max.push(forecastData[0].temp_max)
        max.push(forecastData[1].temp_max)
        max.push(forecastData[2].temp_max)
        max.push(forecastData[3].temp_max)
        max.push(forecastData[4].temp_max)

        plotData(time, min, max)
    }
}
