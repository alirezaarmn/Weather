pragma Singleton
import VPlay 2.0
import QtQuick 2.7

Item {
    id: dataModel

    property bool weatherAvailable: false

    property var weatherData: ({})

    property var forecastData: []

    function clearData()  {//TODO
        // Reset all data stored in the model and the cache
//        setModelData1(false, "", undefined, undefined, "", "", false)
    }

    function updateWeatherFromJson(parsedWeatherJson) {
        dataModel.weatherData = {
            'weatherForCity': parsedWeatherJson.name + ", " + parsedWeatherJson.sys.country,
            'weatherDate': new Date(),//TODO
            'weatherTemp': parsedWeatherJson.main.temp,
            'minWeatherTemp': parsedWeatherJson.main.temp_min,
            'maxWeatherTemp': parsedWeatherJson.main.temp_max,
            'weatherCondition': parsedWeatherJson.weather[0].main,
            'weatherIconUrl': "http://openweathermap.org/img/w/" + parsedWeatherJson.weather[0].icon + ".png"
        }
    }

    function updateForecastFromJson(parsedWeatherForcast) {
        var index = 0
        for(;index < 5; ++index) {
            var temp = {
                'temp_min': parsedWeatherForcast.list[index].main.temp_min,
                'temp_max': parsedWeatherForcast.list[index].main.temp_max,
                'weatherIconUrl': "http://openweathermap.org/img/w/" + parsedWeatherForcast.list[index].weather[0].icon + ".png",
                'weatherCondition': parsedWeatherForcast.list[index].weather[0].main,
                'date': parsedWeatherForcast.list[index].dt_txt
            }

            dataModel.forecastData.push(temp)
        }
    }
}
