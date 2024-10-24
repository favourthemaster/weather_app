class CurrentWeatherModel {
  late DateTime time;
  late double temp;
  late double feelsLikeTemp;
  late double pressure;
  late double humidity;
  late double windSpeed;
  late String title;
  late String iconData;
  late String thermometerIconData;
  late String cardColour;
  late int timeShift;

  CurrentWeatherModel.fromJson(Map<String, dynamic> data) {
    temp = data["main"]["temp"] + 0.0;
    feelsLikeTemp = data["main"]["feels_like"] + 0.0;
    pressure = data["main"]["pressure"] + 0.0;
    humidity = data["main"]["humidity"] + 0.0;
    windSpeed = data["wind"]["speed"] + 0.0;
    timeShift = data["timezone"];
    time = DateTime.fromMillisecondsSinceEpoch((data["dt"] * 1000))
        .add(Duration(seconds: timeShift))
        .subtract(Duration(hours: 1));
    title = data["weather"][0]["description"].toString().splitMapJoin(" ",
        onNonMatch: (s) => s[0].toUpperCase() + s.substring(1));
    iconData = getIconData(data["weather"][0]["id"], time);
    thermometerIconData = getTIconData();
    cardColour = getCardColor();
  }

  setValues(Map<String, dynamic> data) {
    temp = data["main"]["temp"] + 0.0;
    feelsLikeTemp = data["main"]["feels_like"] + 0.0;
    pressure = data["main"]["pressure"] + 0.0;
    humidity = data["main"]["humidity"] + 0.0;
    windSpeed = data["wind"]["speed"] + 0.0;
    timeShift = data["timezone"];
    time = DateTime.fromMillisecondsSinceEpoch((data["dt"] * 1000))
        .add(Duration(seconds: timeShift))
        .subtract(Duration(hours: 1));
    title = data["weather"][0]["description"].toString().splitMapJoin(" ",
        onNonMatch: (s) => s[0].toUpperCase() + s.substring(1));
    iconData = getIconData(data["weather"][0]["id"], time);
    thermometerIconData = getTIconData();
    cardColour = getCardColor();
  }

  String getIconData(int id, DateTime time) {
    if (isDay(time)) {
      if (id.toString().startsWith("2")) {
        return "thunderstorms.json";
      } else if (id.toString().startsWith("3")) {
        return "partly-cloudy-day-rain.json";
      } else if (id >= 500 && id < 600) {
        if (id >= 503) {
          return "extreme-rain.json";
        }
        return "rain.json";
      } else if (id.toString().startsWith("6")) {
        return "snow.json";
      } else if (id == 800) {
        return "clear-day.json";
      } else if (id == 801) {
        return "partly-cloudy-day.json";
      } else if (id == 802) {
        return "cloudy.json";
      } else {
        return "overcast.json";
      }
    } else {
      if (id.toString().startsWith("2")) {
        return "thunderstorms.json";
      } else if (id.toString().startsWith("3")) {
        return "partly-cloudy-night-rain.json";
      } else if (id >= 500 && id < 600) {
        if (id >= 503) {
          return "extreme-rain.json";
        }
        return "rain.json";
      } else if (id.toString().startsWith("6")) {
        return "snow.json";
      } else if (id == 800) {
        return "clear-night.json";
      } else if (id == 801) {
        return "partly-cloudy-night.json";
      } else if (id == 802) {
        return "cloudy.json";
      } else {
        return "overcast.json";
      }
    }
  }

  String getTIconData() {
    if (temp > 27) {
      return "thermometer-warmer.json";
    } else if (temp > 15) {
      return "thermometer.json";
    }
    return "thermometer-colder.json";
  }

  String getCardColor() {
    if (temp > 27) {
      return "red";
    } else if (temp > 15) {
      return "green";
    }
    return "blue";
  }

  bool isDay(DateTime time) {
    return (time.hour >= 6 && time.hour <= 18) ? true : false;
  }
}

class ForecastWeatherModel {
  late DateTime time;
  late double temp;
  late String iconData;

  ForecastWeatherModel.fromJson(Map<String, dynamic> data) {
    temp = data["main"]["temp"] + 0.0;
    time = DateTime.fromMillisecondsSinceEpoch((data["dt"] * 1000));
    iconData = getIconData(data["weather"][0]["id"], time);
  }

  setValues(Map<String, dynamic> data) {
    temp = data["main"]["temp"] + 0.0;
    time = DateTime.fromMillisecondsSinceEpoch((data["dt"] * 1000));
    iconData = getIconData(data["weather"][0]["id"], time);
  }

  String getIconData(int id, DateTime time) {
    if (isDay(time)) {
      if (id.toString().startsWith("2")) {
        return "thunderstorm.json";
      } else if (id.toString().startsWith("3")) {
        return "partly-cloudy-day-rain.json";
      } else if (id >= 500 && id < 600) {
        if (id >= 503) {
          return "extreme-rain.json";
        }
        return "rain.json";
      } else if (id.toString().startsWith("6")) {
        return "snow.json";
      } else if (id == 800) {
        return "clear-day.json";
      } else if (id == 801) {
        return "partly-cloudy-day.json";
      } else if (id == 802) {
        return "cloudy.json";
      } else {
        return "overcast.json";
      }
    } else {
      if (id.toString().startsWith("2")) {
        return "thunderstorm.json";
      } else if (id.toString().startsWith("3")) {
        return "partly-cloudy-night-rain.json";
      } else if (id >= 500 && id < 600) {
        if (id >= 503) {
          return "extreme-rain.json";
        }
        return "rain.json";
      } else if (id.toString().startsWith("6")) {
        return "snow.json";
      } else if (id == 800) {
        return "clear-night.json";
      } else if (id == 801) {
        return "partly-cloudy-night.json";
      } else if (id == 802) {
        return "cloudy.json";
      } else {
        return "overcast.json";
      }
    }
  }

  bool isDay(DateTime time) {
    return (time.hour >= 6 && time.hour <= 18) ? true : false;
  }
}
