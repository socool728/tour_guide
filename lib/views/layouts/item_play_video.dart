import 'package:custom_utils/custom_utils.dart';
import 'package:flutter/material.dart';
import 'dart:io';

import 'package:appinio_video_player/appinio_video_player.dart' as appinio;
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

class ItemPlayVideo extends StatefulWidget {
  String url;


  @override
  _ItemPlayVideoState createState() => _ItemPlayVideoState();

  ItemPlayVideo({
    required this.url,
  });
}

class _ItemPlayVideoState extends State<ItemPlayVideo> {
  appinio.VideoPlayerController? videoPlayerController;
  appinio.CustomVideoPlayerController? customVideoPlayerController;
  int seconds = 0;
  bool loaded = false;

  @override
  void initState() {
    super.initState();
    print(widget.url);
  }


  @override
  void dispose() {
    // Ensure disposing of the VideoPlayerController to free up resources.
    if (videoPlayerController != null) {
      videoPlayerController!.dispose();
      customVideoPlayerController!.dispose();
    }

    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
        future: initializeVideoPlayer(),
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
                      customVideoPlayerProgressBarSettings:
                      appinio.CustomVideoPlayerProgressBarSettings(
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
  }
  Future<void> initializeVideoPlayer() async {
    print(widget.url);
    videoPlayerController = await appinio.VideoPlayerController.network(widget.url);
    customVideoPlayerController = await appinio.CustomVideoPlayerController(
      context: context,
      videoPlayerController: videoPlayerController!,
    );
    await videoPlayerController!.initialize();
  }}


