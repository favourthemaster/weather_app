import 'dart:async';

import 'package:flutter/material.dart';

class ImageBackground extends StatefulWidget {
  final int addedHours;
  const ImageBackground({super.key, required this.addedHours});

  @override
  State<ImageBackground> createState() => _ImageBackgroundState();
}

class _ImageBackgroundState extends State<ImageBackground> {
  int n = 1;
  late Timer _timer;
  late DateTime _currentTime;

  @override
  void initState() {
    super.initState();
    _updateTime();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: double.infinity,
      width: double.infinity,
      child: FittedBox(
        fit: BoxFit.cover,
        child: Image.asset(
          "assets/bg-images/$n.jpg",
          gaplessPlayback: true,
        ),
      ),
    );
  }

  int getImageNo() {
    int hour = _currentTime.hour;
    return hour;
  }

  void _updateTime() {
    setState(() {
      _currentTime = DateTime.now().add(Duration(hours: widget.addedHours - 1));
      n = getImageNo();
    });
    _timer = Timer(const Duration(seconds: 1), _updateTime);
  }
}
