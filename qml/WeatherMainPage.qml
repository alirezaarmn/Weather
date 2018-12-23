import QtQuick 2.4
import QtQuick.Controls 1.2
import "."
import VPlayApps 1.0
import CustomPlot 1.0

Page {
  id: page
  property int currentIndex: 0
  property string errorMsg: ""
  property var cityName: ["Kish", "Sydney", "London", "Tehran", "Vienna", "Graz"]
  readonly property string weatherServiceAppId: "d8ed259735b17a417d92789cd24abae6";

  Connections {
    target: DataModel

    onPlotData: {
        customPlot.setPlotData(time, min, max)
    }
  }

  Component.onCompleted: {
      // send requests and update the model
      loadJsonData("weather")
      loadJsonData("forecast")
  }

  Timer {
    running: true
    interval: 1000 * 10
    triggeredOnStart: true
    repeat: true
    onTriggered: {
        (currentIndex == 5) ? currentIndex = 0 : ++currentIndex
        /*make plot invisible in order to avoid user see unupdated info because
        'forecast' request may takes more time to response. it will be visible when new data arrive*/
        customPlot.setVisiblity(false)
        loadJsonData("weather")
        loadJsonData("forecast")
    }
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
        color: DataModel.weatherData.weatherTemp < 20 ? "#1AD6FD" : "#FF5E3A"

        Behavior on color { ColorAnimation { duration: 1500 } }
      }
      GradientStop {
        position: 1
        color: DataModel.weatherData.weatherTemp < 20 ? "#1D62F0" : "#FF2A68"

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
    anchors.horizontalCenter: parent.horizontalCenter
    y: dp(50)

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

  // Bottom contents
  // display the forcast data for current city in following hours
  Grid {
    id: bottomGrid

    width: Math.min(parent.width - dp(20), dp(450))
    anchors.horizontalCenter: parent.horizontalCenter
    y: parent.height - height - dp(210)
    columns: 5

    Repeater {
      model: [
        //TODO:
        /*
           This part has some weird behavior. It works perfectly with 'dataModel.weatherData'.
           But, with 'DataModel.forecastData' does not work anymore. I don't know why this happens.
           The only difference between these two is that 'DataModel.forecastData' is an array of
           objects but dataModel.weatherData is an object.
        */
        { day: DataModel.forecastData[0].time, high: DataModel.forecastData[0].temp_max, low: DataModel.forecastData[0].temp_min, sourceIcon: DataModel.forecastData[0].weatherIconUrl },
        { day: DataModel.forecastData[1].time, high: DataModel.forecastData[1].temp_max, low: DataModel.forecastData[1].temp_min, sourceIcon: DataModel.forecastData[1].weatherIconUrl },
        { day: DataModel.forecastData[2].time, high: DataModel.forecastData[2].temp_max, low: DataModel.forecastData[2].temp_min, sourceIcon: DataModel.forecastData[2].weatherIconUrl },
        { day: DataModel.forecastData[3].time, high: DataModel.forecastData[3].temp_max, low: DataModel.forecastData[3].temp_min, sourceIcon: DataModel.forecastData[3].weatherIconUrl },
        { day: DataModel.forecastData[4].time, high: DataModel.forecastData[4].temp_max, low: DataModel.forecastData[4].temp_min, sourceIcon: DataModel.forecastData[4].weatherIconUrl }
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
  // dispaly the forcast data for current city in following hours in a plot
  CustomPlotItem {
      id: customPlot
      width: Math.min(parent.width - dp(20), dp(450))
      height: parent.height * 0.25
      anchors.horizontalCenter: parent.horizontalCenter
      y: parent.height - height - dp(10)

      colorBackground: DataModel.weatherData.weatherTemp < 20 ? "#1D62F0" : "#FF2A68"

      Component.onCompleted: {
          initCustomPlot()
      }
  }

  //Script for getting data by REST
  function loadJsonData(type) {
      var xhr = new XMLHttpRequest

      xhr.onreadystatechange = function() {
          if (xhr.readyState === XMLHttpRequest.DONE) {
              var parsedData = xhr.responseText ? JSON.parse(xhr.responseText) : null
            //TODO:
              /*unexpectedly, when JSON is due to response to 'forecast' request,
                despite "parsedData.cod"  is 200, this condition will not raise.
                maybe the type of response in 'forecast' request is different from 'weather' request.
                So, I check the appropriate response of 'forecast' with "parsedData.cnr""
              */
              if (parsedData.cod === 200 && type === "weather") {
                  // Success: received city weather data
                  errorMsg = ""
                  DataModel.updateWeatherFromJson(parsedData)
              }
              else if(parsedData.cnt === 40 && type === "forecast"){
                  DataModel.updateForecastFromJson(parsedData)
              } else {
                  // Issue with the REST request
                  if (xhr.status === 0) {
                      // The request didn't go through, e.g., no Internet connection or the server is down
                      errorMsg = "Unable to send weather request"
                  } else if (parsedData && parsedData.message) {
                      // Received a response, but the server reported the request was not successful
                      errorMsg = parsedData.message
                  } else {
                      // All other cases - print the HTTP response status code / message
                      errorMsg = "Request error: " + xhr.status + " / " + xhr.statusText
                  }
                  DataModel.clearData()
                  console.log("ERORR MSG:"+errorMsg)
              }

          }
      }

      // Build query URL
      var params = "q="+cityName[currentIndex]+"&units=metric&appid=" + weatherServiceAppId
      var temp = "http://api.openweathermap.org/data/2.5/"+type+"?" + params
      xhr.open("GET", temp)
      xhr.send()
  }  

}
