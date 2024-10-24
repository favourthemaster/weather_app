import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weather_app_v2/pages/specific_location_weather_page.dart';
import 'package:weather_app_v2/providers/search_provider.dart';

import '../providers/location_provider.dart';
import '../providers/weather_provider.dart';
import '../widgets/image_bg.dart';

class SpecificLocationForecastPage extends StatelessWidget {
  final TextEditingController searchController = TextEditingController();
  final int addedTime = 0;
  SpecificLocationForecastPage({super.key});

  @override
  Widget build(BuildContext context) {
    bool loaded = false;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SingleChildScrollView(
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          child: Stack(
            children: [
              Consumer<WeatherProvider>(builder: (context, value, child) {
                if (!value.isLoading || loaded) {
                  loaded = true;
                  return ImageBackground(
                    addedHours: (value.cModel.timeShift / 3600).round(),
                  );
                } else {
                  return const SizedBox();
                }
              }),
              SafeArea(
                child: Column(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black26,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Column(
                            children: [
                              SizedBox(
                                width: MediaQuery.of(context).size.width,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12.0, vertical: 24),
                                  child: TextField(
                                    onChanged: (_) {
                                      context
                                          .read<SearchProvider>()
                                          // ignore: no_wildcard_variable_uses
                                          .setSearch(_);
                                    },
                                    controller: searchController,
                                    cursorColor: Colors.black,
                                    style: const TextStyle(
                                      color: Colors.black,
                                    ),
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(
                                          borderSide: BorderSide.none,
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      filled: true,
                                      fillColor: Colors.white,
                                      prefixIcon: const Icon(
                                          Icons.location_searching,
                                          color: Colors.grey),
                                      hintText: "Search for a location",
                                      hintStyle: const TextStyle(
                                          fontSize: 16, color: Colors.grey),
                                    ),
                                  ),
                                ),
                              ),
                              Consumer2<LocationProvider, SearchProvider>(
                                  builder: (context, value, sValue, child) {
                                Future<List> getSearchedStuff() async {
                                  await Future.delayed(
                                      const Duration(milliseconds: 500));
                                  return sValue.search.isEmpty
                                      ? value.locations.toList()
                                      : value.locations
                                          .where((s) => s.name
                                              .toLowerCase()
                                              .contains(
                                                  sValue.search.toLowerCase()))
                                          .toList();
                                }

                                return Expanded(
                                  child: Material(
                                    color: Colors.transparent,
                                    child: FutureBuilder(
                                        future: getSearchedStuff(),
                                        builder: (context, snapshot) {
                                          return snapshot.hasData
                                              ? ListView.builder(
                                                  itemCount:
                                                      snapshot.data!.length,
                                                  itemBuilder:
                                                      (context, index) {
                                                    return ListTile(
                                                      onTap: () {
                                                        Navigator.of(context)
                                                            .push(
                                                                MaterialPageRoute(
                                                          builder: (context) =>
                                                              SpecificLocationWeatherPageScreen(
                                                                  location: snapshot
                                                                          .data![
                                                                      index]),
                                                        ));
                                                      },
                                                      title: Text(
                                                        snapshot
                                                            .data?[index].name,
                                                        style: const TextStyle(
                                                            color:
                                                                Colors.white),
                                                      ),
                                                    );
                                                  },
                                                )
                                              : const Center(
                                                  child:
                                                      CircularProgressIndicator(),
                                                );
                                        }),
                                  ),
                                );
                              }),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 70,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class LocationCard extends StatelessWidget {
  const LocationCard({super.key});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
