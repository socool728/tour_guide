import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:custom_utils/custom_utils.dart';
import 'package:dotted_line/dotted_line.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:read_more_text/read_more_text.dart';
import 'package:tour_guide/extensions/cap_extension.dart';
import 'package:tour_guide/extensions/num_extensions.dart';
import 'package:tour_guide/helpers/permissions_utils.dart';
import 'package:tour_guide/models/stop.dart';
import 'package:tour_guide/models/tour.dart';
import 'package:tour_guide/views/mobileView/screens/screen_user_mobile_home_page.dart';
import 'package:tour_guide/views/mobileView/screens/screen_user_mobile_play_videos.dart';
import 'package:tour_guide/widgets/custom_progress_button.dart';

import '../../../generated/locales.g.dart';
import '../../../helpers/helpers.dart';

class ScreenUserMobileTourDetail extends StatefulWidget {
  Tour tour;

  @override
  _ScreenUserMobileTourDetailState createState() => _ScreenUserMobileTourDetailState();

  ScreenUserMobileTourDetail({
    required this.tour,
  });
}

class _ScreenUserMobileTourDetailState extends State<ScreenUserMobileTourDetail> {
  var showLoading = false;
  var downloadingAssets = false;
  double downloadProgress = 0;
  int totalFiles = 0;
  int downloadedFiles = 0;
  bool tourExists = false;
  List<Stop> stops = [];
  var loading = false;

  @override
  void initState() {
    checkForTour();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: WillPopScope(
          onWillPop: () async {
            if (downloadingAssets) {
              Get.snackbar(
                "Alert",
                "Can't go back until the tour completely downloads.",
                colorText: Colors.black,
                backgroundColor: Colors.white
              );
              return false;
            }
            return true;
          },
          child: CustomProgressWidget(
            loading: loading,
            text: "Removing tour data from device",
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    height: Get.height * (SizerUtil.orientation == Orientation.landscape ? 2 : 1) * .26,
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.vertical(bottom: Radius.circular(12)),
                        image: DecorationImage(
                            fit: BoxFit.cover,
                            image: CachedNetworkImageProvider(widget.tour.imagesUrl.isNotEmpty ? widget.tour.imagesUrl.first : placeholder_url))),
                    child: Stack(
                      // alignment: AlignmentDirectional.center,
                      children: [
                        Positioned.fill(
                            child: Container(
                          color: Color(0xFF4F4F4F).withOpacity(.5),
                        )),
                        Positioned(
                            bottom: 10.sp,
                            left: 10.sp,
                            child: Text(
                              widget.tour.title,
                              style: heading1_style.copyWith(color: Colors.white),
                            )),
                        Positioned(
                            top: 10.sp,
                            left: 10.sp,
                            right: 10.sp,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                IconButton(
                                  onPressed: () {
                                    Get.back();
                                  },
                                  icon: Icon(
                                    Icons.arrow_back_ios_new_outlined,
                                    color: Colors.white,
                                  ),
                                ),
                                if (tourExists)
                                  IconButton(
                                      onPressed: () {
                                        Get.defaultDialog(
                                          title: "Delete offline tour",
                                          content: Text("Are your sure to delete this tour data from device"),
                                          actions: [
                                            OutlinedButton(
                                                onPressed: () {
                                                  Get.back();
                                                },
                                                child: Text("Dismiss")),
                                            OutlinedButton(
                                                onPressed: () async {
                                                  setState(() {
                                                    loading = true;
                                                  });
                                                  await deleteTourData(widget.tour.id);
                                                  setState(() {
                                                    loading = false;
                                                  });
                                                  Get.offAll(ScreenUserMobileHomePage());
                                                },
                                                child: Text("Delete"))
                                          ],
                                        );
                                      },
                                      icon: Icon(
                                        Icons.delete,
                                        color: Colors.white,
                                      ))
                              ],
                            )),
                      ],
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                    decoration: BoxDecoration(
                      boxShadow: appBoxShadow,
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              flex: 2,
                              child: Text(
                                widget.tour.starting_point,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: normal_h3Style_bold.copyWith(color: appPrimaryColor),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Container(
                                child: Column(
                                  children: [
                                    SvgPicture.asset('assets/svgs/directions_car.svg'),
                                    DottedLine(
                                      dashColor: Colors.red,
                                      dashLength: 4,
                                      dashGapLength: 2,
                                      lineThickness: 2,
                                      dashRadius: 30,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                widget.tour.ending_point,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: normal_h3Style_bold.copyWith(color: appPrimaryColor),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 1.h,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: SvgPicture.asset("assets/svgs/distance_larg.svg"),
                                ),
                                Text(
                                  "${(widget.tour.total_distance / 1000).roundToNum(2)} km",
                                  style: normal_h3Style.copyWith(color: appPrimaryColor, fontWeight: FontWeight.w600),
                                )
                              ],
                            ),
                            Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: SvgPicture.asset("assets/svgs/time_required_larg.svg"),
                                ),
                                Text(
                                  "${widget.tour.total_time} min",
                                  style: normal_h3Style.copyWith(color: appPrimaryColor, fontWeight: FontWeight.w600),
                                )
                              ],
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 1.h,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: SvgPicture.asset("assets/svgs/location_larg.svg"),
                                ),
                                Text(
                                  LocaleKeys.StopsN.tr.replaceAll("000", "${widget.tour.total_stop}"),
                                  style: normal_h3Style.copyWith(color: appPrimaryColor, fontWeight: FontWeight.w600),
                                )
                              ],
                            ),
                            Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: SvgPicture.asset("assets/svgs/directions_car_larg.svg"),
                                ),
                                Text(
                                  widget.tour.source,
                                  style: normal_h3Style.copyWith(color: appPrimaryColor, fontWeight: FontWeight.w600),
                                )
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: Get.width,
                    margin: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                    decoration: BoxDecoration(
                      boxShadow: appBoxShadow,
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${LocaleKeys.Description.tr}",
                          style: normal_h1Style_bold.copyWith(color: appPrimaryColor),
                        ),
                        SizedBox(
                          height: 1.h,
                        ),
                        ReadMoreText(widget.tour.description,
                            numLines: 12,
                            readMoreIconColor: appPrimaryColor,
                            readMoreText: LocaleKeys.ReadMore.tr,
                            readLessText: LocaleKeys.Less.tr,
                            readMoreTextStyle: TextStyle(color: appPrimaryColor))
                      ],
                    ),
                  ),
                  Builder(builder: (context) {
                    downloadProgress = (downloadedFiles / (totalFiles == 0 ? 1 : totalFiles)) * 100;
                    if (downloadProgress.round() == 100) {
                      checkForTour();
                    }

                    return tourExists
                        ? CustomButton(
                            text: "Explore Tour",
                            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 25.sp),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(Radius.circular(32)),
                            ),
                            onPressed: () async {
                              getAllStops().then((value) {
                                stops = value.where((e) => e.tour_id == widget.tour.id).toList();
                              });
                              if (widget.tour.stop_ids != null) {
                                var allStops = await getAllStops();
                                widget.tour.stop_ids!.forEach((e) {
                                  var stop = allStops.where((element) => element.id == e).toList().first;
                                  stops.add(stop);
                                });
                              }

                              Get.to(ScreenUserMobilePlayVideos(stops: stops, tour: widget.tour, offline: true));
                            })
                        : CustomProgressButton(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(Radius.circular(32)),
                            ),
                            buttonType: downloadingAssets ? ButtonType.progress : ButtonType.clickable,
                            progress: downloadProgress,
                            progressText: "Downloading (${downloadProgress.round()} %)",
                            text: LocaleKeys.DownloadAssets.tr,
                            onPressed: () async {
                              if (!downloadingAssets) {
                                startDownloading();
                              }
                            });
                  })
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void startDownloading() async {
    var status = await PermissionUtils.checkStorageWritePermission();
    if (status.isGranted) {
      setState(() {
        downloadingAssets = true;
      });

      totalFiles += widget.tour.imagesUrl.length;
      totalFiles += widget.tour.videosUrl.length;
      totalFiles += widget.tour.audiosUrl.length;

      var stopsDocs = (await stopsRef.where("tour_id", isEqualTo: widget.tour.id).get()).docs;
      var stops = stopsDocs.map((e) => Stop.fromMap(e.data() as Map<String, dynamic>)).toList();
      stops.forEach((element) {
        totalFiles += element.stopAudiosUrl.length;
        totalFiles += element.stopImagesUrl.length;
        totalFiles += element.stopVideosUrl.length;
      });

      var tourImagesPath = await PermissionUtils.createPathDirectory(".$appName/tours/${widget.tour.id}/images/");
      var tourVideosPath = await PermissionUtils.createPathDirectory(".$appName/tours/${widget.tour.id}/videos/");
      var tourAudiosPath = await PermissionUtils.createPathDirectory(".$appName/tours/${widget.tour.id}/audios/");

      setState(() {});

      await Future.forEach(widget.tour.imagesUrl, (String element) async {
        await downloadFromFirebase(url: element, savedDir: tourImagesPath);
        setState(() {
          downloadedFiles++;
        });
      });
      await Future.forEach(widget.tour.videosUrl, (String element) async {
        await downloadFromFirebase(url: element, savedDir: tourVideosPath);
        setState(() {
          downloadedFiles++;
        });
      });
      await Future.forEach(widget.tour.audiosUrl, (String element) async {
        await downloadFromFirebase(url: element, savedDir: tourAudiosPath);
        setState(() {
          downloadedFiles++;
        });
      });

      await Future.forEach(stops, (Stop element) async {
        var stopImagesPath = await PermissionUtils.createPathDirectory(".$appName/stops/${element.id}/images/");
        var stopVideosPath = await PermissionUtils.createPathDirectory(".$appName/stops/${element.id}/videos/");
        var stopAudiosPath = await PermissionUtils.createPathDirectory(".$appName/stops/${element.id}/audios/");

        await Future.forEach(element.stopImagesUrl, (String element) async {
          await downloadFromFirebase(url: element, savedDir: stopImagesPath);
          setState(() {
            downloadedFiles++;
          });
        });
        await Future.forEach(element.stopVideosUrl, (String element) async {
          await downloadFromFirebase(url: element, savedDir: stopVideosPath);
          setState(() {
            downloadedFiles++;
          });
        });
        await Future.forEach(element.stopAudiosUrl, (String element) async {
          await downloadFromFirebase(url: element, savedDir: stopAudiosPath);
          setState(() {
            downloadedFiles++;
          });
        });

        await addStop(element);
      });

      await addTour(widget.tour);
      setState(() {
        downloadingAssets = false;
      });
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

  void checkForTour() async {
    var exists = await PermissionUtils.checkIfTourExists(widget.tour.id);
    setState(() {
      tourExists = exists;
    });
  }
}
