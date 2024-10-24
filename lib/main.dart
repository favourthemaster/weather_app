import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';
import 'package:weather_app_v2/pages/home_screen.dart';
import 'package:weather_app_v2/pages/specific_location_search_page.dart';
import 'package:weather_app_v2/providers/location_provider.dart' as loc;
import 'package:weather_app_v2/providers/page_provider.dart';
import 'package:weather_app_v2/providers/search_provider.dart';
import 'package:weather_app_v2/providers/weather_provider.dart';

bool locationPermissionGranted = false;
bool locationPermissionPermanentlyDenied = false;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Check location permissions and services
  await checkLocationPermissionsAndServices();

  if (locationPermissionGranted && !locationPermissionPermanentlyDenied) {
    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => PageProvider()),
          ChangeNotifierProvider(create: (_) => WeatherProvider()),
          ChangeNotifierProvider(create: (_) => SpecificWeatherProvider()),
          ChangeNotifierProvider(create: (_) => ForecastProvider()),
          ChangeNotifierProvider(create: (_) => SpecificForecastProvider()),
          ChangeNotifierProvider(create: (_) => loc.LocationProvider()),
          ChangeNotifierProvider(create: (_) => SearchProvider()),
        ],
        child: const MyApp(),
      ),
    );
  } else {
    runApp(const PermissionNotGrantedApp());
  }
}

Future<void> checkLocationPermissionsAndServices() async {
  final Location location = Location();

  try {
    // Check location services
    bool serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        // Handle location services denied
        return;
      }
    }

    // Check permission status
    PermissionStatus permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted == PermissionStatus.denied) {
        // Handle permission denied
        return;
      } else if (permissionGranted == PermissionStatus.deniedForever) {
        locationPermissionPermanentlyDenied = true;
      } else {
        locationPermissionGranted = true;
      }
    } else {
      locationPermissionGranted = true;
    }
  } on Exception {
    // Handle error
  }
}

var _pages = [
  const HomeScreen(),
  SpecificLocationForecastPage(),
];

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark().copyWith(
          colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.white,
              primary: Colors.white,
              onSurface: Colors.white,
              surface: const Color.fromRGBO(26, 28, 30, 1))),
      home: Scaffold(
        body: Consumer<PageProvider>(
          builder: (context, value, child) => Stack(
            children: [
              _pages[value.page],
              Positioned(
                bottom: 0,
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: 70,
                  decoration: const BoxDecoration(color: Colors.black38),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                          onPressed: () {
                            value.setPage(0);
                          },
                          icon: Icon(
                            Icons.sunny,
                            color: value.page == 0 ? Colors.white : Colors.grey,
                            size: 30,
                          )),
                      IconButton(
                          onPressed: () {
                            value.setPage(1);
                          },
                          icon: Icon(
                            Icons.location_on,
                            color: value.page == 1 ? Colors.white : Colors.grey,
                            size: 30,
                          )),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PermissionNotGrantedApp extends StatelessWidget {
  const PermissionNotGrantedApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark(),
      home: const Scaffold(
        body: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "We can't access your location because location services are permanently disabled on your device, and/or location permission for our app is not enabled. To continue using our app, close the app and please enable both.",
                style: TextStyle(
                  fontSize: 20,
                ),
              ),
              Text(
                "How to Enable:\n\nEnable Location Services:\n1. Tap Settings\n2. Scroll down and select Location\n3. Toggle Location Services to On\n\nEnable Location Permission for Our App:\n\n1. Tap Settings\n2. Scroll down and select Apps or Application Manager\n3. Select our app\n4. Tap Permissions\n5. Enable Location\n",
                style: TextStyle(
                  fontSize: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
