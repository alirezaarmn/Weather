import QtQuick 2.4
import QtQuick.Controls 1.2
import "."
import VPlayApps 1.0

Page {
  id: page
  property int currentIndex: 0
  property string errorMsg: ""
  property string cityName: "Sydney"
  readonly property string weatherServiceAppId: "d8ed259735b17a417d92789cd24abae6";

  Component.onCompleted: {
      loadJsonData("weather")
      loadJsonData("forecast")
  }

  // Background
  Rectangle {
    x: -page.safeArea.x
    y: -page.safeArea.y
    width: page.width
    height: page.height

    gradient: Gradient {
      GradientStop {
        position: 0
        color: today.temperature < 20 ? "#1AD6FD" : "#FF5E3A"

        Behavior on color { ColorAnimation { duration: 1500 } }
      }
      GradientStop {
        position: 1
        color: today.temperature < 20 ? "#1D62F0" : "#FF2A68"

        Behavior on color { ColorAnimation { duration: 1000 } }
      }
    }
  }

  // Top content
  Column {
    anchors.horizontalCenter: parent.horizontalCenter
    y: dp(10)
    spacing: dp(10)

    // Current time
    AppText {
      id: timeLabel

      font.pixelSize: sp(14)
      anchors.horizontalCenter: parent.horizontalCenter

      Timer {
        running: true
        interval: 1000 * 30
        triggeredOnStart: true
        repeat: true
        onTriggered: {
          timeLabel.text = new Date().toLocaleTimeString(Qt.locale(), Locale.ShortFormat)
        }
      }
    }

    // City
    AppText {
      text: DataModel.weatherData.weatherForCity
      font.pixelSize: sp(22)
      anchors.horizontalCenter: parent.horizontalCenter
    }

  }

  // Centered content
  Column {
    id: col
    anchors.centerIn: parent

    // Temperature
    AppText {
      id: tempText

      property int temperature: DataModel.weatherData.weatherTemp

      Component.onCompleted: text = temperature

      font.pixelSize: sp(140)
      anchors.horizontalCenter: parent.horizontalCenter

      onTemperatureChanged: {
        var currentTemp = parseInt(tempText.text)
        textTimer.restart()
      }

      Timer {
        id: textTimer
        interval: 40

        onTriggered: {
          // Check if we have to change the text
          var currentTemp = parseInt(tempText.text)

          if (tempText.temperature > currentTemp) {
            tempText.text = ++currentTemp
            restart()
          }
          else if (tempText.temperature < currentTemp) {
            tempText.text = --currentTemp
            restart()
          }
        }
      }
    }

    // Description
    AppText {
      id: descText
      text: DataModel.weatherData.weatherCondition
      font.pixelSize: sp(28)
      anchors.horizontalCenter: parent.horizontalCenter

      Behavior on text {
        SequentialAnimation {
          NumberAnimation { target: descText; property: "opacity"; to: 0 }
          PropertyAction { }
          NumberAnimation { target: descText; property: "opacity"; to: 1 }
        }
      }
    }
  }

  // Bottom content
  Grid {
    id: bottomGrid

    width: Math.min(parent.width - dp(20), dp(450))
    anchors.horizontalCenter: parent.horizontalCenter
    y: parent.height - height - dp(10)
    columns: 5

    Repeater {
      model: [
        { day: Qt.locale().dayName(0, Locale.ShortFormat), high: DataModel.weatherData.maxWeatherTemp, low: DataModel.weatherData.minWeatherTemp, sourceIcon: DataModel.weatherData.weatherIconUrl },//TODO: wiered behaviour
        { day: Qt.locale().dayName(0, Locale.ShortFormat), high: DataModel.forecastData[1].temp_max, low: DataModel.forecastData[1].temp_min, sourceIcon: DataModel.forecastData[1].weatherIconUrl },
        { day: Qt.locale().dayName(2, Locale.ShortFormat), high: DataModel.forecastData[2].temp_max, low: DataModel.forecastData[2].temp_min, sourceIcon: DataModel.forecastData[2].weatherIconUrl },
        { day: Qt.locale().dayName(3, Locale.ShortFormat), high: DataModel.forecastData[3].temp_max, low: DataModel.forecastData[3].temp_min, sourceIcon: DataModel.forecastData[3].weatherIconUrl },
        { day: Qt.locale().dayName(4, Locale.ShortFormat), high: DataModel.forecastData[4].temp_max, low: DataModel.forecastData[4].temp_min, sourceIcon: DataModel.forecastData[4].weatherIconUrl }
      ]

      Column {
        width: bottomGrid.width / 5
        spacing: dp(5)

        Image {
          source: modelData.sourceIcon
          anchors.horizontalCenter: parent.horizontalCenter
          sourceSize: dp(20)
        }

        Item {
          width: 1
          height: dp(5)
        }

        AppText {
          text: modelData.high
          anchors.horizontalCenter: parent.horizontalCenter
          font.pixelSize: sp(14)
        }

        AppText {
          text: modelData.low
          color: "#aaffffff"
          anchors.horizontalCenter: parent.horizontalCenter
          font.pixelSize: sp(14)
        }

        Item {
          width: 1
          height: dp(5)
        }

        AppText {
          text: modelData.day
          anchors.horizontalCenter: parent.horizontalCenter
          font.pixelSize: sp(14)
        }
      }
    }
  }

  function loadJsonData(type) {
      var xhr = new XMLHttpRequest

      xhr.onreadystatechange = function() {
          if (xhr.readyState === XMLHttpRequest.DONE) {
//              console.log("DONE: " + xhr.status + " / " + xhr.responseText)
              var parsedData = xhr.responseText ? JSON.parse(xhr.responseText) : null

//              if (parsedData.cod === 200) {
                  // Success: received city weather data
                  errorMsg = ""

                  if (type === "weather") {
                    DataModel.updateWeatherFromJson(parsedData)
                  } else if (type === "forecast") {
                    DataModel.updateForecastFromJson(parsedData)
                  }
//              } else {
//                  // Issue with the REST request
//                  if (xhr.status === 0) {
//                      // The request didn't go through, e.g., no Internet connection or the server is down
//                      errorMsg = "Unable to send weather request"
//                  } else if (parsedData && parsedData.message) {
//                      // Received a response, but the server reported the request was not successful
//                      errorMsg = parsedData.message
//                  } else {
//                      // All other cases - print the HTTP response status code / message
//                      errorMsg = "Request error: " + xhr.status + " / " + xhr.statusText
//                  }
//                  DataModel.clearData()
//                  console.log("ERORR MSG:"+errorMsg)
//              }

          }
      }

      // Build query URL
      var params = "q="+cityName+"&units=metric&appid=" + weatherServiceAppId
      var temp = "http://api.openweathermap.org/data/2.5/"+type+"?" + params
      console.log(temp)
      xhr.open("GET", temp)
      xhr.send()
  }  

}
