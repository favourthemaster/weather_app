import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:weather_app_v2/models/weather_model.dart';
import 'package:weather_app_v2/providers/location_provider.dart';
import 'package:weather_app_v2/providers/weather_provider.dart';
import 'package:weather_app_v2/widgets/image_bg.dart';

import '../variables.dart';

class SpecificLocationWeatherPageScreen extends StatelessWidget {
  final Location location;

  const SpecificLocationWeatherPageScreen({super.key, required this.location});

  @override
  Widget build(BuildContext context) {
    String lat;
    String long;
    bool loaded = false;
    var coordinates =
        context.read<LocationProvider>().getCoordsFromLoc(location);
    lat = coordinates[0];
    long = coordinates[1];
    context
        .read<SpecificForecastProvider>()
        .init(double.parse(lat), double.parse(long));
    context
        .read<SpecificWeatherProvider>()
        .setUp(lat: double.parse(lat), long: double.parse(long));
    context
        .read<SpecificWeatherProvider>()
        .watchSpecData(double.parse(lat), double.parse(long));
    context.read<SpecificForecastProvider>().watchData();
    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        print("destroyed");
        disposeSpecificResources();
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: SingleChildScrollView(
          child: SizedBox(
            height: MediaQuery.of(context).size.height,
            child: Stack(
              children: [
                Consumer<SpecificWeatherProvider>(
                    builder: (context, value, child) {
                  if ((!value.isSpecLoading || loaded) && !isError) {
                    loaded = true;
                    return ImageBackground(
                      addedHours: (value.specModel!.timeShift / 3600).round(),
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
                              child: Consumer2<SpecificWeatherProvider,
                                      LocationProvider>(
                                  builder: (context, value, lValue, child) {
                                if (!value.isSpecLoading &&
                                    !lValue.isLoading &&
                                    !isError) {
                                  return Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                        height: 16,
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            Variables.getStringDate(
                                                value.specModel!.time),
                                            style: const TextStyle(
                                              fontSize: 18,
                                            ),
                                          ),
                                          const SizedBox(
                                            width: 16,
                                          ),
                                          Text(
                                            Variables.getFullStringTime(
                                                value.specModel!.time),
                                            style: const TextStyle(
                                              fontSize: 18,
                                            ),
                                          ),
                                        ],
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
                                                  snapshot.data! ==
                                                          "Remote Unknown Area"
                                                      ? location.name
                                                      : snapshot.data!,
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
                                            "assets/weather_lotties/${value.specModel!.iconData}"),
                                      ),
                                      Text(
                                        value.specModel!.title,
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
                                    (!value.isSpecLoading &&
                                        !lValue.isLoading)) {
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
                                                value.setUp(
                                                    lat: double.parse(lat),
                                                    long: double.parse(long));
                                                context
                                                    .read<
                                                        SpecificForecastProvider>()
                                                    .init(double.parse(lat),
                                                        double.parse(long));
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
                          child: Consumer2<SpecificWeatherProvider,
                              LocationProvider>(
                            builder: (context, value, lValue, child) => (!value
                                        .isSpecLoading &&
                                    !lValue.isLoading &&
                                    !isError)
                                ? Container(
                                    height: double.infinity,
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      color: value.specModel!.cardColour ==
                                              "red"
                                          ? Colors.red.withOpacity(.6)
                                          : (value.specModel!.cardColour ==
                                                  "green"
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
                                                "assets/weather_lotties/${value.specModel!.thermometerIconData}"),
                                          ),
                                          const Expanded(child: SizedBox()),
                                          Column(
                                            children: [
                                              Text(
                                                "${value.specModel!.temp.round()}℃",
                                                style: const TextStyle(
                                                  fontSize: 54,
                                                ),
                                              ),
                                              Text(
                                                "Real Feel ${value.specModel!.feelsLikeTemp.round()}℃",
                                                style: const TextStyle(
                                                  fontSize: 15,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                : const Center(
                                    child: CircularProgressIndicator(),
                                  ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Consumer2<SpecificWeatherProvider,
                              LocationProvider>(
                            builder: (context, value, lValue, child) => (!value
                                        .isSpecLoading &&
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
                                                    "${value.specModel!.windSpeed}m/s",
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
                                                    "${value.specModel!.pressure.round()} MB",
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
                                                    "${value.specModel!.humidity.round()}%",
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
                            child: Consumer2<SpecificForecastProvider,
                                    LocationProvider>(
                                builder: (context, value, lValue, child) {
                              return (!value.isSpecLoading &&
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
                    ],
                  ),
                ),
                Positioned(
                  top: 40,
                  left: 20,
                  child: IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                    ),
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
