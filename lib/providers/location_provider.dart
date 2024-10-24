import 'dart:async';
import 'dart:convert';

import 'package:country_state_city/country_state_city.dart' as cs;
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:weather_app_v2/constants.dart';

late List<cs.Country> countries;
late List<cs.State> states;
late List<cs.City> cities;

class Location {
  late String name;
  late String countryCode;
  String? stateCode;
  bool isCountry = false;
  bool isState = false;
  bool isCity = false;

  Location.fromCity(cs.City city) {
    cs.Country country =
        countries.firstWhere((c) => c.isoCode == city.countryCode);
    cs.State state = states.firstWhere((s) => s.isoCode == city.stateCode);
    name = "${city.name}, ${state.name}, ${country.name}";
    countryCode = country.isoCode;
    stateCode = state.isoCode;
    isCity = true;
  }

  Location.fromState(cs.State state) {
    cs.Country country =
        countries.firstWhere((c) => c.isoCode == state.countryCode);
    name = " ${state.name}, ${country.name}";
    countryCode = country.isoCode;
    stateCode = state.isoCode;
    isState = true;
  }

  Location.fromCountry(cs.Country country) {
    name = country.name;
    countryCode = country.isoCode;
    isCountry = true;
  }
}

class LocationProvider extends ChangeNotifier {
  List<Location> locations = [];
  bool isLoading = true;
  String location = "";

  LocationProvider() {
    getAll();
  }

  Future<void> getLocations() async {
    await Future(() async {
      for (var i in countries) {
        locations.add(Location.fromCountry(i));
      }
      for (var i in states) {
        locations.add(Location.fromState(i));
      }
      for (var i in cities) {
        locations.add(Location.fromCity(i));
      }
    }).then((_) {
      notifyListeners();
    });
  }

  Future<void> getAll() async {
    print("here1");
    countries = await cs.getAllCountries();
    states = await cs.getAllStates();
    cities = await cs.getAllCities();
    await getLocations();
    isLoading = false;
    notifyListeners();
  }

  Future<String> getLocationFromCoordinates(double lat, double long) async {
    String cityName = '';
    String countryShort = '';
    String url =
        "http://api.openweathermap.org/geo/1.0/reverse?lat=$lat&lon=$long&limit=1&appid=$apiKey";
    http.Response response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      if (data.isEmpty) {
        return 'Remote Unknown Area';
      }
      cityName = data[0]["name"];
      countryShort = data[0]["country"];
    }
    cs.City city = cities.firstWhere(
      (city) =>
          (city.name == cityName && city.countryCode == countryShort) ||
          (city.name.contains(cityName) && city.countryCode == countryShort),
      orElse: () =>
          cs.City(name: cityName, countryCode: countryShort, stateCode: "null"),
    );
    // cities.firstWhere((city) =>
    //     (city.name == cityName) && (city.countryCode == countryShort));

    if (city.stateCode == "null") {
      cs.Country country =
          countries.firstWhere((c) => c.isoCode == city.countryCode);
      return "${country.name}, ${city.name}";
    }
    cs.Country country =
        countries.firstWhere((c) => c.isoCode == city.countryCode);
    cs.State state = states.firstWhere((s) => s.isoCode == city.stateCode);
    location = "${country.name}, ${state.name}, ${city.name}";
    return location;
  }

  List<String> getCoordsFromLoc(Location loc) {
    print(loc.name.split(",")[0]);
    print(loc.stateCode);
    print(loc.countryCode);
    if (loc.isCity) {
      cs.City city = cities.singleWhere((city) =>
          (city.name == loc.name.split(",")[0].trim()) &&
          (city.stateCode == loc.stateCode) &&
          (city.countryCode == loc.countryCode));
      return [city.latitude.toString(), city.longitude.toString()];
    } else if (loc.isState) {
      cs.State state = states.singleWhere((state) =>
          (state.name == loc.name.split(",")[0].trim()) &&
          (state.countryCode == loc.countryCode));
      return [state.latitude.toString(), state.longitude.toString()];
    } else {
      cs.Country country = countries.singleWhere((country) =>
          (country.name == loc.name) && (country.isoCode == loc.countryCode));
      return [country.latitude.toString(), country.longitude.toString()];
    }
  }
}
