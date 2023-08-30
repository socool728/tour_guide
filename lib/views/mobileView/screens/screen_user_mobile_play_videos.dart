import 'dart:io';

import 'package:appinio_video_player/appinio_video_player.dart' as appinio;
import 'package:custom_utils/custom_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tour_guide/generated/locales.g.dart';
import 'package:tour_guide/models/stop.dart';
import 'package:tour_guide/views/mobileView/screens/screen_user_location.dart';
import 'package:tour_guide/views/mobileView/screens/screen_user_mobile_tour_description.dart';

import '../../../helpers/helpers.dart';
import '../../../helpers/permissions_utils.dart';
import '../../../models/tour.dart';

class ScreenUserMobilePlayVideos extends StatefulWidget {
  Tour tour;
  bool offline;
  List<Stop> stops;

  @override
  _ScreenUserMobilePlayVideosState createState() => _ScreenUserMobilePlayVideosState();

  ScreenUserMobilePlayVideos({
    required this.tour,
    required this.stops,
    required this.offline,
  });
}

class _ScreenUserMobilePlayVideosState extends State<ScreenUserMobilePlayVideos> {
  double value = 50;
  appinio.VideoPlayerController? videoPlayerController;
  appinio.CustomVideoPlayerController? customVideoPlayerController;
  int seconds = 0;
  bool loaded = false;

  @override
  void initState() {
    super.initState();
    // print(widget.url);
  }

  @override
  void dispose() {
    // Ensure disposing of the VideoPlayerController to free up resources.
    disposeVideoPlayer();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Container(
          color: Colors.black,
          height: Get.height,
          width: Get.width,
          child: Stack(
            children: [
              Positioned.fill(
                child: PageView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: widget.tour.videosUrl.length,
                  itemBuilder: (BuildContext context, int index) {
                    return FutureBuilder<void>(
                        future: initializeVideoPlayer(index),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.done) {
                            seconds = videoPlayerController!.value.duration.inSeconds;
                            loaded = true;
                            videoPlayerController!.play();
                            return Container(
                              height: Get.height,
                              width: Get.width,
                              child: appinio.CustomVideoPlayer(
                                customVideoPlayerController: appinio.CustomVideoPlayerController(
                                  context: context,
                                  videoPlayerController: videoPlayerController!,
                                  customVideoPlayerSettings: appinio.CustomVideoPlayerSettings(
                                      customVideoPlayerProgressBarSettings: appinio.CustomVideoPlayerProgressBarSettings(
                                          allowScrubbing: true,
                                          progressBarHeight: 5.sp,
                                          progressBarBorderRadius: 25,
                                          progressColor: buttonColor,
                                          showProgressBar: true),
                                      showPlayButton: true,
                                      showFullscreenButton: true,
                                      controlBarAvailable: true),
                                ),
                              ),
                            );
                          }

                          return Center(
                            child: CircularProgressIndicator.adaptive(),
                          );
                        });
                  },
                ),
              ),
              Positioned(
                  top: 20.sp,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                          onPressed: () {
                            Get.back();
                          },
                          icon: Icon(
                            Icons.arrow_back_ios_new_outlined,
                            color: Colors.white,
                          )),
                      TextButton(
                          onPressed: () {
                            videoPlayerController?.pause();
                            Get.off(ScreenUserLocation(
                              tour: widget.tour,
                              stop: widget.stops,
                              offline: widget.offline,
                            ));
                          },
                          child: Text(
                            LocaleKeys.Skip.tr,
                            style: normal_h2Style.copyWith(color: Colors.white),
                          ))
                    ],
                  )),

              // Center(
              //   child: Row(
              //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //     children: [
              //       Container(
              //         padding: EdgeInsets.all(10),
              //         margin: EdgeInsets.all(6),
              //         decoration: BoxDecoration(
              //             shape: BoxShape.circle,
              //             color: Colors.white.withOpacity(.40)),
              //         child: Icon(
              //           Icons.arrow_back_ios_new_outlined,
              //           color: appPrimaryColor,
              //         ),
              //       ),
              //       Text(
              //         LocaleKeys.IntroductionVideo.tr,
              //         style: heading3_style.copyWith(color: Colors.white),
              //       ),
              //       Container(
              //         padding: EdgeInsets.all(10),
              //         margin: EdgeInsets.all(6),
              //         decoration: BoxDecoration(
              //             shape: BoxShape.circle,
              //             color: Colors.white.withOpacity(.40)),
              //         child: Icon(
              //           Icons.arrow_forward_ios,
              //           color: appPrimaryColor,
              //         ),
              //       ),
              //     ],
              //   ),
              // ),
              Positioned(
                  bottom: 35.sp,
                  left: 0,
                  right: 0,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () {
                          videoPlayerController?.pause();
                          Get.off(ScreenUserMobileTourDescription(
                            tour: widget.tour,
                            offline: true,
                            stops: widget.stops,
                          ));
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 10),
                          child: Text(
                            LocaleKeys.SeeIntroductionDescription.tr,
                            style: TextStyle(decoration: TextDecoration.underline, fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white),
                          ),
                        ),
                      )
                    ],
                  ))
            ],
          ),
        ),
      ),
    );
  }

  Future<void> initializeVideoPlayer(int index) async {
    // print(widget.url);
    if (widget.offline) {
      var path = await PermissionUtils.createPathDirectory(".$appName/tours/${widget.tour.id}/videos");
      videoPlayerController = await appinio.VideoPlayerController.file(File("$path/_$index.mp4"));
    } else {
      videoPlayerController = await appinio.VideoPlayerController.network(widget.tour.videosUrl[index]);
    }

    customVideoPlayerController = await appinio.CustomVideoPlayerController(
      context: context,
      videoPlayerController: videoPlayerController!,
    );
    await videoPlayerController!.initialize();
  }

  void disposeVideoPlayer() {
    if (videoPlayerController != null) {
      videoPlayerController!.dispose();
      customVideoPlayerController!.dispose();
    }
  }
}
