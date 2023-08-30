import 'dart:async';
import 'dart:developer';

import 'package:custom_utils/custom_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:tour_guide/helpers/helpers.dart';
import 'package:tour_guide/views/mobileView/screens/screen_user_mobile_stops_list.dart';
import 'package:polyline_do/polyline_do.dart' as polyline_do;
import 'package:tour_guide/views/mobileView/screens/screen_user_play_stop_videos.dart';
import '../../../helpers/location_utils.dart';
import '../../../models/stop.dart';
import '../../../models/tour.dart';
import '../layouts/item_audio_play.dart';

class ScreenUserLocation extends StatefulWidget {
  Tour tour;
  List<Stop> stop;
  bool offline;

  @override
  _ScreenUserLocationState createState() => _ScreenUserLocationState();

  ScreenUserLocation({
    required this.tour,
    required this.stop,
    required this.offline,
  });
}

class _ScreenUserLocationState extends State<ScreenUserLocation> {
  Completer<GoogleMapController> mapController = Completer();

  Set<Marker> _markers = Set<Marker>();
  late LatLng currentLocation;
  late LatLng destinationLocation;

  final Set<Polyline> polyline = {};
  final Set<Marker> markers = {};
  var listenerStarted = false;
  var stop;
  int index = 0;
  StreamSubscription? locationStream;
  List<Stop> stopsPlayed = [];
  var isPlaying = false;
  var showAudios = false;
  Stop? stopForAudios;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    if (locationStream != null) {
      locationStream!.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios),
            onPressed: () {
              Get.back();
            },
          ),
          title: Text("Location"),
          actions: [
            IconButton(
                onPressed: () {
                  Get.to(ScreenUserMobileStopsList(
                    stops: widget.stop,
                    offline: widget.offline,
                    draggable: false,
                  ));
                },
                icon: Icon(Icons.menu))
          ],
        ),
        body: Container(
          height: Get.height,
          width: Get.width,
          child: FutureBuilder<bool>(
              future: checkPermissionStatus(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
                if (snapshot.data == false) {
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
                return Builder(builder: (context) {
                  widget.stop.sort((a, b) => a.stop_number.compareTo(b.stop_number));

                  startListener();
                  markers.add(
                    Marker(
                        markerId: MarkerId("start"),
                        position: LatLng(widget.tour.startLat, widget.tour.startLng),
                        infoWindow: InfoWindow(title: widget.tour.title, snippet: "Start Point"),
                        icon: BitmapDescriptor.defaultMarker),
                  );

                  markers.addAll(widget.stop
                      .map(
                        (e) => Marker(
                            markerId: MarkerId(e.id),
                            position: LatLng(e.latitude, e.longitude),
                            infoWindow: InfoWindow(title: "Stop", snippet: e.name),
                            icon: BitmapDescriptor.defaultMarker),
                      )
                      .toList());

                  markers.add(
                    Marker(
                        markerId: MarkerId("end"),
                        position: LatLng(widget.tour.endLat, widget.tour.endLng),
                        infoWindow: InfoWindow(title: widget.tour.title, snippet: "End Point"),
                        icon: BitmapDescriptor.defaultMarker),
                  );

                  return Container(
                    height: Get.height,
                    width: Get.width,
                    child: Column(
                      children: [
                        Expanded(
                          child: GoogleMap(
                            mapType: MapType.normal,
                            myLocationEnabled: true,
                            compassEnabled: false,
                            myLocationButtonEnabled: true,
                            tiltGesturesEnabled: false,
                            polylines: {
                              Polyline(
                                polylineId: PolylineId(""),
                                points: [
                                  LatLng(widget.tour.startLat, widget.tour.startLng),
                                  ...widget.stop.map((e) => LatLng(e.latitude, e.longitude)).toList(),
                                  LatLng(widget.tour.endLat, widget.tour.endLng),
                                ],
                                color: appPrimaryColor,
                                width: 4,
                              )
                            },
                            markers: markers,
                            onMapCreated: (GoogleMapController controller) {
                              mapController.complete(controller);
                            },
                            initialCameraPosition: CameraPosition(
                              target: LatLng(widget.tour.startLat, widget.tour.startLng),
                              zoom: 18,
                            ),
                          ),
                        ),
                        if (showAudios && stopForAudios != null && stopForAudios!.stopAudiosUrl.isNotEmpty)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  Text("${stopForAudios!.stopAudiosUrl.length} audios for stop \"${stopForAudios!.name}\""),
                                  TextButton(
                                      onPressed: () {
                                        setState(() {
                                          showAudios = false;
                                          stopForAudios = null;
                                        });
                                      },
                                      child: Text("Close")),
                                ],
                              ),
                              StatefulBuilder(builder: (context, setState) {
                                return CustomListviewBuilder(
                                  itemBuilder: (BuildContext context, index) {
                                    return ItemAudioPlay(
                                      url: stopForAudios!.stopAudiosUrl[index],
                                      isPlaying: (playing) {
                                        setState(() {
                                          isPlaying = playing;
                                        });
                                      },
                                      disabled: isPlaying,
                                    );
                                  },
                                  itemCount: stopForAudios!.stopAudiosUrl.length,
                                  scrollDirection: CustomDirection.horizontal,
                                );
                              }),
                            ],
                          )
                      ],
                    ),
                  );
                });
              }),
        ),
      ),
    );
  }

  void startListener() {
    if (!mounted) {
      return;
    }
    if (!listenerStarted) {
      locationStream = Geolocator.getPositionStream().listen((event) {
        log("${event}");

        widget.stop.forEach((element) {
          if (!stopsPlayed.contains(element)) {
            var distance = getDistance(event.latitude, event.longitude, element.latitude, element.longitude);
            log("Distance $distance");
            if (distance <= 350) {
              showDialogForStop(element, distance);
            }
          }
        });
      });
      listenerStarted = true;
    }
  }

  void showDialogForStop(Stop stop, double distance) {
    if (!mounted) {
      return;
    }

    stopsPlayed.add(stop);
    Get.defaultDialog(
        title: "New Stop \"${stop.name}\"",
        content: Text("New stop is coming within $distance meters. Would you like to play the media?"),
        actions: [
          OutlinedButton(
              onPressed: () async {
                Get.back();
                await Get.to(ScreenUserPlayStopVideos(stop: stop, offline: true));
                setState(() {
                  stopForAudios = stop;
                  showAudios = true;
                });
              },
              child: Text("Yes")),
          OutlinedButton(
              onPressed: () {
                Get.back();
              },
              child: Text("No")),
        ]);
  }

// Future<PolylineResult> generatePolylines(List<Stop> stops) async {
//   PolylinePoints polylinePoints = PolylinePoints();
//   var polyline = polyline_do.Polyline.Encode(decodedCoords: stops.map((e) => [e.latitude, e.longitude]).toList(), precision: 5);
//   List<PointLatLng> decodedResult = polylinePoints.decodePolyline(polyline.encodedString);
//   polylinePoints.decodePolyline(polyline.encodedString);
//   return decodedResult;
// }
}
