import 'package:custom_utils/custom_utils.dart';
import 'package:flutter/material.dart';

import '../../../models/stop.dart';

class ScreenAddCustomTour extends StatefulWidget {


  List<Stop> stops;


  @override
  _ScreenAddCustomTourState createState() => _ScreenAddCustomTourState();

  ScreenAddCustomTour({
    required this.stops,
  });
}

class _ScreenAddCustomTourState extends State<ScreenAddCustomTour> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [

        ],
      ),
    );
  }
}
