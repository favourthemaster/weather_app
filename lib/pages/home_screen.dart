import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:weather_app_v2/models/weather_model.dart';
import 'package:weather_app_v2/providers/location_provider.dart';
import 'package:weather_app_v2/providers/weather_provider.dart';
import 'package:weather_app_v2/widgets/image_bg.dart';

import '../variables.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    bool loaded = false;
    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        disposeCurrentResources();
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: SingleChildScrollView(
          child: SizedBox(
            height: MediaQuery.of(context).size.height,
            child: Stack(
              children: [
                Consumer<WeatherProvider>(builder: (context, value, child) {
                  if ((!value.isLoading || loaded) && !isError) {
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
                        flex: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                              height: double.infinity,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: Colors.black12,
                              ),
                              child:
                                  Consumer2<WeatherProvider, LocationProvider>(
                                      builder: (context, value, lValue, child) {
                                if (!value.isLoading &&
                                    !lValue.isLoading &&
                                    !isError) {
                                  return Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                        height: 16,
                                      ),
                                      Text(
                                        Variables.getStringDate(
                                            value.cModel.time),
                                        style: const TextStyle(
                                          fontSize: 18,
                                        ),
                                      ),
                                      FutureBuilder(
                                        future:
                                            lValue.getLocationFromCoordinates(
                                                value.lat, value.long),
                                        builder: (context, snapshot) {
                                          return snapshot.hasData
                                              ? Text(
                                                  maxLines: 2,
                                                  softWrap: true,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  snapshot.data!,
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                    color: Colors.white70,
                                                  ),
                                                )
                                              : (snapshot.hasError
                                                  ? Text(
                                                      snapshot.error.toString())
                                                  : const SizedBox());
                                        },
                                      ),
                                      Expanded(
                                        child: Lottie.asset(
                                            "assets/weather_lotties/${value.cModel.iconData}"),
                                      ),
                                      Text(
                                        value.cModel.title,
                                        style: const TextStyle(
                                          fontSize: 24,
                                        ),
                                      ),
                                      SizedBox(
                                        height: 16,
                                      ),
                                    ],
                                  );
                                } else if (isError &&
                                    (!value.isLoading && !lValue.isLoading)) {
                                  WidgetsBinding.instance
                                      .addPostFrameCallback((_) {
                                    showDialog(
                                      barrierDismissible: false,
                                      context: context,
                                      builder: (context) => PopScope(
                                        canPop: false,
                                        child: AlertDialog(
                                          title: const Text('Error'),
                                          actions: [
                                            TextButton(
                                              onPressed: () {
                                                Navigator.pop(context);
                                                value.init();
                                                context
                                                    .read<ForecastProvider>()
                                                    .init();
                                              },
                                              child: const Text("Retry"),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                SystemChannels.platform
                                                    .invokeMethod(
                                                        'SystemNavigator.pop');
                                              },
                                              child: const Text(
                                                "Close",
                                                style: TextStyle(
                                                    color: Colors.grey),
                                              ),
                                            ),
                                          ],
                                          content: const Text(
                                              'An error occurred\nCheck your internet connection and try again'),
                                        ),
                                      ),
                                    );
                                  });
                                  return const SizedBox();
                                } else {
                                  return const SizedBox();
                                }
                              })),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Consumer2<WeatherProvider, LocationProvider>(
                              builder: (context, value, lValue, child) {
                            if (!value.isLoading &&
                                !lValue.isLoading &&
                                !isError) {
                              return Container(
                                height: double.infinity,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: value.cModel.cardColour == "red"
                                      ? Colors.red.withOpacity(.6)
                                      : (value.cModel.cardColour == "green"
                                          ? Colors.green.withOpacity(.6)
                                          : Colors.blue.withOpacity(.7)),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Lottie.asset(
                                            "assets/weather_lotties/${value.cModel.thermometerIconData}"),
                                      ),
                                      const Expanded(child: SizedBox()),
                                      Column(
                                        children: [
                                          Text(
                                            "${value.cModel.temp.round()}℃",
                                            style: const TextStyle(
                                              fontSize: 54,
                                            ),
                                          ),
                                          Text(
                                            "Real Feel ${value.cModel.feelsLikeTemp.round()}℃",
                                            style: const TextStyle(
                                              fontSize: 15,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            } else if ((value.isLoading || lValue.isLoading)) {
                              print(lValue.isLoading);
                              print(value.isLoading);
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            } else {
                              return const SizedBox();
                            }
                          }),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Consumer2<WeatherProvider, LocationProvider>(
                            builder: (context, value, lValue, child) => (!value
                                        .isLoading &&
                                    !lValue.isLoading &&
                                    !isError)
                                ? Row(
                                    children: [
                                      Expanded(
                                        flex: 1,
                                        child: Container(
                                          height: double.infinity,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(20),
                                            color: Colors.black26,
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(16.0),
                                            child: Center(
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  const Icon(
                                                    Icons.air,
                                                    size: 30,
                                                  ),
                                                  const Text(
                                                    "Wind",
                                                    style: TextStyle(
                                                      fontSize: 18,
                                                    ),
                                                  ),
                                                  Text(
                                                    "${value.cModel.windSpeed}m/s",
                                                    style: const TextStyle(
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 8,
                                      ),
                                      Expanded(
                                        flex: 1,
                                        child: Container(
                                          height: double.infinity,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(20),
                                            color: Colors.black26,
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(16.0),
                                            child: Center(
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  const Icon(
                                                    Icons.device_thermostat,
                                                    size: 30,
                                                  ),
                                                  const Text(
                                                    "Pressure",
                                                    style: TextStyle(
                                                      fontSize: 18,
                                                    ),
                                                  ),
                                                  Text(
                                                    "${value.cModel.pressure.round()} MB",
                                                    style: const TextStyle(
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 8,
                                      ),
                                      Expanded(
                                        flex: 1,
                                        child: Container(
                                          height: double.infinity,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(20),
                                            color: Colors.black26,
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(16.0),
                                            child: Center(
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  const Icon(
                                                    Icons.water_drop,
                                                    size: 30,
                                                  ),
                                                  const Text(
                                                    "Humidity",
                                                    style: TextStyle(
                                                      fontSize: 18,
                                                    ),
                                                  ),
                                                  Text(
                                                    "${value.cModel.humidity.round()}%",
                                                    style: const TextStyle(
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                : const SizedBox(),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.black26,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child:
                                Consumer2<ForecastProvider, LocationProvider>(
                                    builder: (context, value, lValue, child) {
                              return (!value.isLoading &&
                                      !lValue.isLoading &&
                                      !isError)
                                  ? Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: List.generate(
                                        5,
                                        (index) => ForecastBox(
                                            fModel: value.fModels[index]),
                                      ),
                                    )
                                  : const SizedBox();
                            }),
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
      ),
    );
  }
}

class ForecastBox extends StatelessWidget {
  final ForecastWeatherModel fModel;
  const ForecastBox({super.key, required this.fModel});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              Variables.getStringTime(fModel.time),
              style: TextStyle(
                fontSize: 14,
                color: fModel.time.day == DateTime.now().day
                    ? Colors.white
                    : Colors.white60,
              ),
            ),
            Lottie.asset("assets/weather_lotties/${fModel.iconData}",
                width: 40),
            Text(
              "${fModel.temp}℃",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: fModel.time.day == DateTime.now().day
                    ? Colors.white
                    : Colors.white60,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
