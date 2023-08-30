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

class ScreenUserPlayStopVideos extends StatefulWidget {
  Stop stop;
  bool offline;

  @override
  _ScreenUserPlayStopVideosState createState() => _ScreenUserPlayStopVideosState();

  ScreenUserPlayStopVideos({
    required this.stop,
    required this.offline,
  });
}

class _ScreenUserPlayStopVideosState extends State<ScreenUserPlayStopVideos> {
  double value = 50;
  appinio.VideoPlayerController? videoPlayerController;
  appinio.CustomVideoPlayerController? customVideoPlayerController;
  int seconds = 0;
  bool loaded = false;

  @override
  void initState() {
    super.initState();

    startPlayer(0);
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
                  itemCount: widget.stop.stopVideosUrl.length,
                  itemBuilder: (BuildContext context, int index) {
                    return videoPlayerController != null
                        ? Container(
                            height: Get.height,
                            width: MediaQuery.of(context).size.width,
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
                          )
                        : Center(child: Text("Starting vide"));
                  },
                  onPageChanged: (index) async {
                    startPlayer(index);
                  },
                ),
              ),
              Positioned(
                  top: 20.sp,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                          onPressed: () {
                            Get.back();
                          },
                          icon: Icon(
                            Icons.clear,
                            color: Colors.white,
                          )),
                    ],
                  )),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> initializeVideoPlayer(int index) async {
    print(widget.stop.id);
    if (widget.offline) {
      var path = await PermissionUtils.createPathDirectory(".$appName/stops/${widget.stop.id}/videos/");
      videoPlayerController = await appinio.VideoPlayerController.file(File("$path/_$index.mp4"));
    } else {
      videoPlayerController = await appinio.VideoPlayerController.network(widget.stop.stopVideosUrl[index]);
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

  void startPlayer(int index) async {
    if (videoPlayerController != null) {
      videoPlayerController!.dispose();
    }
    await initializeVideoPlayer(index);
    seconds = videoPlayerController!.value.duration.inSeconds;
    loaded = true;
    videoPlayerController!.play();
    setState(() {});
  }
}
