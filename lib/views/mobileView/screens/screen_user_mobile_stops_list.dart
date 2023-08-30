import 'dart:io';

import 'package:custom_utils/custom_utils.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:tour_guide/extensions/cap_extension.dart';
import 'package:tour_guide/generated/locales.g.dart';
import 'package:tour_guide/models/stop.dart';
import 'package:tour_guide/models/tour.dart';
import 'package:tour_guide/views/mobileView/screens/screen_user_mobile_home_page.dart';

import '../../../helpers/helpers.dart';
import '../../../helpers/permissions_utils.dart';
import '../../layouts/item_user_stops_list.dart';

class ScreenUserMobileStopsList extends StatefulWidget {
  List<Stop> stops;
  bool draggable;
  bool offline;

  @override
  _ScreenUserMobileStopsListState createState() => _ScreenUserMobileStopsListState();

  ScreenUserMobileStopsList({
    required this.stops,
    required this.offline,
    required this.draggable,
  });
}

class _ScreenUserMobileStopsListState extends State<ScreenUserMobileStopsList> {
  var loading = false;
  String title = "", des = "";

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(LocaleKeys.StopsList.tr),
          leading: IconButton(
            onPressed: () {
              Get.back();
            },
            icon: Icon(Icons.arrow_back_ios_new_outlined),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Tooltip(
                message: 'Long press to drag stops and arrange',
                child: Icon(
                  Icons.info_outline,
                  color: Colors.grey,
                ),
                triggerMode: TooltipTriggerMode.tap,
              ),
            )
          ],
        ),
        body: CustomProgressWidget(
          text: "Creating custom tour",
          loading: loading,
          child: widget.stops.isNotEmpty
              ? (widget.draggable
                  ? SingleChildScrollView(
                      child: Column(
                        children: [
                          ReorderableListView(
                            onReorder: (int oldIndex, int newIndex) {
                              if (newIndex > oldIndex) {
                                newIndex--;
                              }
                              final item = widget.stops.removeAt(oldIndex);
                              widget.stops.insert(newIndex, item);
                              widget.stops[newIndex].stop_number = newIndex;
                              setState(() {});
                            },
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            children: widget.stops
                                .map((e) => ItemUserStopsList(
                                      stop: e,
                                      key: ValueKey(e),
                                      offline: widget.offline,
                                    ))
                                .toList(),
                          ),
                          CustomInputField(
                            label: "Title",
                            onChange: (value) {
                              title = value.toString();
                            },
                          ),
                          CustomInputField(
                            maxLines: 5,
                            label: "Description",
                            onChange: (value) {
                              des = value.toString();
                            },
                          ),
                        ],
                      ),
                    )
                  : ListView(
                      children: widget.stops.map((e) => ItemUserStopsList(offline: widget.offline, stop: e)).toList(),
                    ))
              : NotFound(message: "No stops added"),
        ),
        floatingActionButton: widget.draggable
            ? FloatingActionButton.extended(
                onPressed: loading
                    ? null
                    : () {
                        if (title.isEmpty || des.isEmpty) {
                          Get.snackbar("Alert", "Both title and description required");
                          return;
                        }

                        var timestamp = DateTime.now().millisecondsSinceEpoch;
                        var tour = Tour(
                          id: timestamp.toString(),
                          title: title,
                          starting_point: "Custom",
                          ending_point: "Custom",
                          source: "Taxi",
                          description: des,
                          total_stop: widget.stops.length,
                          total_time: 0,
                          time_stamp: timestamp,
                          total_distance: 0,
                          startLat: widget.stops.first.latitude,
                          startLng: widget.stops.first.longitude,
                          endLat: widget.stops.last.latitude,
                          endLng: widget.stops.last.longitude,
                          imagesUrl: widget.stops.first.stopImagesUrl,
                          audiosUrl: widget.stops.first.stopAudiosUrl,
                          videosUrl: widget.stops.first.stopVideosUrl,
                        );
                        startDownloading(tour);
                      },
                label: Text("Create"),
                icon: Icon(Icons.check),
              )
            : null,
      ),
    );
  }

  Future<void> startDownloading(Tour tour) async {
    var status = await PermissionUtils.checkStorageWritePermission();
    if (status.isGranted) {
      setState(() {
        loading = true;
      });

      var tourImagesPath = await PermissionUtils.createPathDirectory(".$appName/tours/${tour.id}/images/");
      var tourVideosPath = await PermissionUtils.createPathDirectory(".$appName/tours/${tour.id}/videos/");
      var tourAudiosPath = await PermissionUtils.createPathDirectory(".$appName/tours/${tour.id}/audios/");
      await Future.forEach(widget.stops.first.stopImagesUrl, (String element) async {
        await downloadFromFirebase(url: element, savedDir: tourImagesPath);
      });
      await Future.forEach(widget.stops.first.stopVideosUrl, (String element) async {
        await downloadFromFirebase(url: element, savedDir: tourVideosPath);
      });
      await Future.forEach(widget.stops.first.stopAudiosUrl, (String element) async {
        await downloadFromFirebase(url: element, savedDir: tourAudiosPath);
      });

      List<String> stopsAdded = [];

      await Future.forEach(widget.stops, (Stop element) async {
        var stopImagesPath = await PermissionUtils.createPathDirectory(".$appName/stops/${element.id}/images/");
        var stopVideosPath = await PermissionUtils.createPathDirectory(".$appName/stops/${element.id}/videos/");
        var stopAudiosPath = await PermissionUtils.createPathDirectory(".$appName/stops/${element.id}/audios/");

        await Future.forEach(element.stopImagesUrl, (String element) async {
          await downloadFromFirebase(url: element, savedDir: stopImagesPath);
        });
        await Future.forEach(element.stopVideosUrl, (String element) async {
          await downloadFromFirebase(url: element, savedDir: stopVideosPath);
        });
        await Future.forEach(element.stopAudiosUrl, (String element) async {
          await downloadFromFirebase(url: element, savedDir: stopAudiosPath);
        });

        await addStop(element);
        stopsAdded.add(element.id);
      });
      await addTour(tour.copyWith(stop_ids: stopsAdded));

      setState(() {
        loading = false;
      });

      Get.offAll(ScreenUserMobileHomePage());
    }
  }

  Future<void> downloadFromFirebase({required String url, required String savedDir}) async {
    var ref = await FirebaseStorage.instance.refFromURL(url.removeToken);
    print(ref.name);

    try {
      await ref.writeToFile(File("$savedDir/${ref.name}"));
    } on FirebaseException catch (e) {
      // e.g, e.code == 'canceled'
      print('Download error: $e');
    }
  }
}

class MyTooltip extends StatelessWidget {
  final Widget child;
  final String message;

  MyTooltip({required this.message, required this.child});

  @override
  Widget build(BuildContext context) {
    final key = GlobalKey<State<Tooltip>>();
    return Tooltip(
      key: key,
      message: message,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _onTap(key),
        child: child,
      ),
    );
  }

  void _onTap(GlobalKey key) {
    final dynamic tooltip = key.currentState;
    tooltip?.ensureTooltipVisible();
  }
}
