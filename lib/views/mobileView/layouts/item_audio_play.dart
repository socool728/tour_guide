import 'package:audioplayers/audioplayers.dart';
import 'package:custom_utils/custom_utils.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

class ItemAudioPlay extends StatefulWidget {
  // List audiosList;
  String url;
  Function(bool isPlaying)? isPlaying;
  bool? disabled;

  // int index;
  @override
  _ItemAudioPlayState createState() => _ItemAudioPlayState();

  ItemAudioPlay({required this.url, this.isPlaying, this.disabled});
// ItemAudioPlay({
//   required this.audiosList,
//   required this.index,
// });
}

class _ItemAudioPlayState extends State<ItemAudioPlay> {
  bool isPlaying = false;
  bool mute = false;

  final audioPlayer = AudioPlayer();
  Duration duration = Duration.zero;
  Duration position = Duration.zero;

  @override
  void dispose() {
    audioPlayer.dispose();
    super.dispose();
  }

  @override
  void initState() {
    audioPlayer.onPlayerStateChanged.listen((event) {
      setState(() {
        isPlaying = event == PlayerState.playing;
        if (widget.isPlaying != null) {
          widget.isPlaying!(isPlaying);
        }
      });
    });
    audioPlayer.onDurationChanged.listen((newDuration) {
      setState(() {
        duration = newDuration;
      });
    });
    audioPlayer.onPositionChanged.listen((newPosition) {
      setState(() {
        position = newPosition;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: Get.width * .8,
      padding: EdgeInsets.symmetric(horizontal: 10),
      margin: EdgeInsets.symmetric(vertical: 5.sp, horizontal: 5),
      decoration: BoxDecoration(boxShadow: appBoxShadow, color: Colors.white),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () async {
              if (widget.disabled != null && widget.disabled == true && !isPlaying) {
                Get.snackbar(
                  "Alert",
                  "Please pause another playing audio first",
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                  snackPosition: SnackPosition.BOTTOM
                );
                return;
              }

              if (!isPlaying) {
                await audioPlayer.setSourceUrl(widget.url);
                await audioPlayer.audioCache;
                await audioPlayer.resume();
                setState(() {});
              } else {
                await audioPlayer.pause();
              }
            },
            icon: (isPlaying)
                ? Icon(
                    Icons.pause,
                    color: Colors.red,
                  )
                : SvgPicture.asset(
                    "assets/svgs/playAudio.svg",
                    height: 20.sp,
                  ),
          ),
          Expanded(
            child: Column(
              children: [
                Slider(
                    min: 0,
                    max: duration.inSeconds.toDouble(),
                    value: position.inSeconds.toDouble(),
                    onChanged: (value) async {
                      final position = Duration(seconds: value.toInt());
                      await audioPlayer.seek(position);
                      // await audioPlayer.resume();
                    }),
                Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text("${timeStampToDateTime(position.inMilliseconds, "mm:ss")}"),
                    Text("${timeStampToDateTime(duration.inMilliseconds - position.inMilliseconds, "mm:ss")}"),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              setState(() {
                mute = !mute;
                (mute) ? audioPlayer.setVolume(0) : audioPlayer.setVolume(1);
              });
            },
            icon: (mute)
                ? Icon(
                    Icons.mic_off,
                    size: 26,
                    color: appPrimaryColor,
                  )
                : Icon(
                    Icons.mic,
                    size: 26.sp,
                    color: appPrimaryColor,
                  ),
          ),
        ],
      ),
    );
  }
}
