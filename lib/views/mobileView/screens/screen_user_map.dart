import 'dart:async';

import 'package:custom_utils/custom_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:tour_guide/generated/locales.g.dart';
import 'package:tour_guide/views/layouts/item_user_tour_audio.dart';

import '../../../helpers/directions_repository.dart';

class ScreenUserMap extends StatefulWidget {
  const ScreenUserMap({Key? key}) : super(key: key);

  @override
  _ScreenUserMapState createState() => _ScreenUserMapState();
}

class _ScreenUserMapState extends State<ScreenUserMap> {
  Completer<GoogleMapController> _controller = Completer();

  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  static final CameraPosition _kLake = CameraPosition(
      bearing: 192.8334901395799, target: LatLng(37.43296265331129, -122.08832357078792), tilt: 59.440717697143555, zoom: 19.151926040649414);

  Marker? _destination;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () {
              Get.back();
            },
            icon: Icon(Icons.arrow_back_ios_new_outlined),
          ),
          title: Text(LocaleKeys.MapGuide.tr),
          actions: [
            IconButton(
                onPressed: () {
                  // Get.to(ScreenUserMobileStopsList());
                },
                icon: Icon(Icons.list))
          ],
        ),
        body: Container(
          height: Get.height,
          width: Get.width,
          child: Stack(
            children: [
              GoogleMap(
                mapType: MapType.normal,
                initialCameraPosition: _kGooglePlex,
                zoomControlsEnabled: false,
                onMapCreated: (GoogleMapController controller) {
                  _controller.complete(controller);
                },

              ),
              Positioned(
                  left: 0,
                  right: 0,
                  bottom: 10,
                  child: Container(
                    height: Get.height * .2,
                    child: CustomListviewBuilder(
                      itemBuilder: (BuildContext context, int index) {
                        return ItemUserTourAudio();
                      },
                      itemCount: 10,
                      scrollDirection: CustomDirection.horizontal,
                    ),
                  ))
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _goToTheLake() async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(_kLake));
  }


}
