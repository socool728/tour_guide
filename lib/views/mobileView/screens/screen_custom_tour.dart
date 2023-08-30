import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:custom_utils/custom_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:tour_guide/views/mobileView/screens/screen_user_mobile_stops_list.dart';

import '../../../helpers/helpers.dart';
import '../../../helpers/location_utils.dart';
import '../../../models/stop.dart';

class ScreenCustomTour extends StatefulWidget {
  @override
  _ScreenCustomTourState createState() => _ScreenCustomTourState();
}

class _ScreenCustomTourState extends State<ScreenCustomTour> {
  Completer<GoogleMapController> mapController = Completer();

  Set<Marker> _markers = Set<Marker>();
  late LatLng currentLocation;
  late LatLng destinationLocation;

  final Set<Polyline> polyline = {};
  final Set<Marker> markers = {};
  List<Stop> selectedStops = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
        future: checkPermissionStatus(),
        builder: (context, permissionSnapshot) {
          if (permissionSnapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          if (permissionSnapshot.data == false) {
            return Center(
              child: Column(
                children: [
                  Text("Location Access Denied"),
                  CustomButton(
                      text: "Retry",
                      onPressed: () {
                        setState(() {});
                      })
                ],
              ),
            );
          }
          return FutureBuilder<Position>(
              future: Geolocator.getCurrentPosition(),
              builder: (context, positionSnapshot) {
                if (positionSnapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CupertinoActivityIndicator());
                }

                var position = positionSnapshot.data!;

                return FutureBuilder<QuerySnapshot>(
                    future: stopsRef.get(),
                    builder: (context, stopSnapshot) {
                      if (stopSnapshot.connectionState == ConnectionState.waiting) {
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                      var stops = stopSnapshot.data!.docs.map((e) => Stop.fromMap(e.data() as Map<String, dynamic>)).toList();
                      return SafeArea(
                        child: StatefulBuilder(builder: (context, setState) {
                          return Scaffold(
                            appBar: AppBar(
                              title: Text("${selectedStops.length} stops selected"),
                            ),
                            body: GoogleMap(
                              myLocationEnabled: true,
                              compassEnabled: false,
                              tiltGesturesEnabled: false,
                              // polylines: {
                              //   Polyline(
                              //     polylineId: PolylineId(""),
                              //     points: [
                              //       ...stops.map((e) => LatLng(e.latitude, e.longitude)).toList(),
                              //     ],
                              //     color: appPrimaryColor,
                              //     width: 4,
                              //   )
                              // },
                              markers: stops
                                  .map(
                                    (e) => Marker(
                                        markerId: MarkerId(e.id),
                                        position: LatLng(e.latitude, e.longitude),
                                        infoWindow: InfoWindow(title: "Stop", snippet: e.name),
                                        onTap: () {
                                          if (stopExists(e.id)) {
                                            selectedStops.remove(e);
                                          } else {
                                            selectedStops.add(e);
                                          }
                                          setState(() {});
                                        },
                                        icon: stopExists(e.id)
                                            ? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen)
                                            : BitmapDescriptor.defaultMarker),
                                  )
                                  .toList()
                                  .toSet(),
                              onMapCreated: (GoogleMapController controller) {
                                mapController.complete(controller);
                              },
                              initialCameraPosition: CameraPosition(
                                target: LatLng(position.latitude, position.longitude),
                                zoom: 13,
                              ),
                            ),
                            floatingActionButton: selectedStops.length > 1
                                ? FloatingActionButton(
                                    onPressed: () {
                                      Get.to(ScreenUserMobileStopsList(offline: true,stops: selectedStops, draggable: true,));
                                    },
                                    child: Icon(Icons.navigate_next),
                                  )
                                : null,
                          );
                        }),
                      );
                    });
              });
        });
  }

  bool stopExists(String id) {
    return selectedStops.where((element) => element.id == id).toList().isNotEmpty;
  }
}
