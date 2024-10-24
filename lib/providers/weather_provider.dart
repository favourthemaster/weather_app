import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:weather_app_v2/models/weather_model.dart';
import 'package:weather_app_v2/utils/location_finder.dart';

import '../constants.dart';

bool isError = false;
var specificForecastStream;
var specificWeatherStream;
var weatherStream;
var forecastStream;

void disposeSpecificResources() {
  if (specificForecastStream != null) {
    specificForecastStream.cancel();
  }
  if (specificWeatherStream != null) {
    specificWeatherStream.cancel();
  }
}

void disposeCurrentResources() {
  if (weatherStream != null) {
    weatherStream.cancel();
  }
  if (forecastStream != null) {
    forecastStream.cancel();
  }
}

class WeatherProvider extends ChangeNotifier {
  late Position _p;
  bool isLoading = true;
  bool isSpecLoading = true;
  late double _lat;
  late double _long;
  late String url;
  late String country;
  late String city;
  late CurrentWeatherModel cModel;

  double get lat => _lat;
  double get long => _long;

  Future<void> setDetails() async {
    _p = await LocationFinder.determinePosition();
    _lat = _p.latitude;
    _long = _p.longitude;
    // country = await getCountryFromCode()
    url =
        "https://api.openweathermap.org/data/2.5/weather?lat=$_lat&lon=$_long&appid=$apiKey&units=metric";
  }

  Map<String, dynamic> data = {};
  WeatherProvider() {
    init();
    watchData();
  }

  Future<void> init() async {
    isError = false;
    isLoading = true;
    notifyListeners();
    await getData();
    if (!isError) {
      cModel = CurrentWeatherModel.fromJson(data);
    }
  }

  Future<void> getData() async {
    try {
      await setDetails();
      http.Response response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        data = jsonDecode(response.body);
        isLoading = false;
        notifyListeners();
      }
    } on Exception catch (e) {
      isLoading = false;
      notifyListeners();
      if (!isError) {
        isError = true;
        notifyListeners();
      }
    }
  }

  void watchData() {
    Duration currentDelay = const Duration(minutes: 10);
    weatherStream = Stream.periodic(currentDelay, (_) async {}).listen((_) {
      print("hey${DateTime.now().toString()}");
      isLoading = true;
      notifyListeners();
      getData();
      cModel.setValues(data);
    });
  }
}

class ForecastProvider extends ChangeNotifier {
  late Position _p;
  bool isLoading = true;
  static late double _lat;
  static late double _long;
  static late String url;
  Map<String, dynamic> data = {};
  List<dynamic> forecast = [];
  List<ForecastWeatherModel> fModels = [];

  Future<void> setDetails() async {
    _p = await LocationFinder.determinePosition();
    _lat = _p.latitude;
    _long = _p.longitude;
    url =
        "https://api.openweathermap.org/data/2.5/forecast?lat=$_lat&lon=$_long&appid=$apiKey&units=metric";
  }

  ForecastProvider() {
    init();
    watchData();
  }

  Future<void> init() async {
    isError = false;
    isLoading = true;
    await getData();
    if (!isError) {
      addForecastModels();
    }
  }

  Future<void> getData() async {
    try {
      await setDetails();
      http.Response response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        data = jsonDecode(response.body);
        forecast = data["list"];
        isLoading = false;
        notifyListeners();
      }
    } on Exception catch (e) {
      isLoading = false;
      notifyListeners();
      if (!isError) {
        isError = true;
        notifyListeners();
      }
    }
  }

  void watchData() {
    if (!isError) {
      Duration currentDelay = const Duration(minutes: 10);
      forecastStream = Stream.periodic(currentDelay, (_) async {}).listen((_) {
        getData();
        setForecastModels();
      });
    }
  }

  void addForecastModels() {
    for (int i = 0; i < forecast.length; i++) {
      fModels.add(ForecastWeatherModel.fromJson(forecast[i]));
    }
  }

  void setForecastModels() {
    for (int i = 0; i < forecast.length; i++) {
      fModels[i].setValues(forecast[i]);
    }
  }
}

class SpecificForecastProvider extends ChangeNotifier {
  bool isSpecLoading = true;
  static late String url;
  Map<String, dynamic> data = {};
  List<dynamic> forecast = [];
  List<ForecastWeatherModel> fModels = [];

  SpecificForecastProvider();

  Future<void> init(double lat, double long) async {
    isError = false;
    url =
        "https://api.openweathermap.org/data/2.5/forecast?lat=$lat&lon=$long&appid=$apiKey&units=metric";
    await getData();
    if (!isError) {
      addForecastModels();
    }
  }

  Future<void> getData() async {
    try {
      http.Response response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        data = jsonDecode(response.body);
        forecast = data["list"];
        isSpecLoading = false;
        notifyListeners();
      }
    } on Exception catch (e) {
      isSpecLoading = false;
      notifyListeners();
      if (!isError) {
        isError = true;
        notifyListeners();
      }
    }
  }

  void watchData() {
    if (!isError) {
      Duration currentDelay = const Duration(minutes: 10);
      specificForecastStream =
          Stream.periodic(currentDelay, (_) async {}).listen((_) {
        getData();
        setForecastModels();
      });
    }
  }

  void addForecastModels() {
    for (int i = 0; i < forecast.length; i++) {
      fModels.add(ForecastWeatherModel.fromJson(forecast[i]));
    }
  }

  void setForecastModels() {
    for (int i = 0; i < forecast.length; i++) {
      fModels[i].setValues(forecast[i]);
    }
  }
}

class SpecificWeatherProvider extends ChangeNotifier {
  bool isSpecLoading = true;
  late double _lat;
  late double _long;
  late String url;
  late String country;
  late String city;

  CurrentWeatherModel? specModel;

  double get lat => _lat;
  double get long => _long;

  SpecificWeatherProvider();

  Future<void> setUp({
    required double lat,
    required double long,
  }) async {
    isError = false;
    print(isSpecLoading);
    _lat = lat;
    _long = long;
    getSpecData(lat, long);
  }

  Future<void> getSpecData(double lat, double long) async {
    //isSpecLoading = true;
    try {
      http.Response response = await http.get(Uri.parse(
          "https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$long&appid=$apiKey&units=metric"));
      if (response.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(response.body);
        specModel ??= CurrentWeatherModel.fromJson(data);
        specModel?.setValues(data);
        isSpecLoading = false;
        notifyListeners();
      }
    } on Exception catch (e) {
      isSpecLoading = false;
      notifyListeners();
      if (!isError) {
        isError = true;
        notifyListeners();
      }
    }
  }

  void watchSpecData(double lat, double long) {
    Duration currentDelay = const Duration(minutes: 10);
    specificWeatherStream =
        Stream.periodic(currentDelay, (_) async {}).listen((_) {
      print("yooo");
      isSpecLoading = true;
      notifyListeners();
      getSpecData(lat, long);
    });
  }
}
