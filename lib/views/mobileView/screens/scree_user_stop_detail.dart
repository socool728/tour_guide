import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_controller.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:custom_utils/custom_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tour_guide/models/stop.dart';
import 'package:tour_guide/views/mobileView/layouts/item_audio_play.dart';
import 'package:tour_guide/views/mobileView/screens/screen_user_play_stop_videos.dart';

import '../../../helpers/helpers.dart';
import '../../../helpers/permissions_utils.dart';

class ScreeUserStopDetail extends StatefulWidget {
  Stop stop;
  bool offLine;

  @override
  _ScreeUserStopDetailState createState() => _ScreeUserStopDetailState();

  ScreeUserStopDetail({
    required this.stop,
    required this.offLine,
  });
}

class _ScreeUserStopDetailState extends State<ScreeUserStopDetail> {
  CarouselController buttonCarouselController = CarouselController();
  bool play = false;
  bool silent = false;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            widget.stop.name,
          ),
          centerTitle: true,
          leading: IconButton(
            onPressed: () {
              Get.back();
            },
            icon: Icon(Icons.arrow_back_ios_new_outlined),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                height: Get.height* (SizerUtil.orientation == Orientation.landscape ? 2 : 1) *.35,
                width: MediaQuery.of(context).size.width,
                color: Colors.red,
                child: Stack(
                  children: [
                    (widget.stop.stopImagesUrl.isEmpty)?SizedBox(
                      child: Center(child: Text("No Images",style: normal_h1Style.copyWith(color: Colors.white),)),
                    ):CarouselSlider.builder(
                      itemCount: widget.stop.stopImagesUrl.length,
                      carouselController: buttonCarouselController,
                      options: CarouselOptions(
                        autoPlay: false,
                        height: Get.height* (SizerUtil.orientation == Orientation.landscape ? 2 : 1) *.35,
                        reverse: false,
                        enlargeCenterPage: true,
                        viewportFraction: 1,
                        aspectRatio: 16 / 9,
                        // initialPage: widget.stop.stopImagesUrl..length,
                      ),
                      itemBuilder: (BuildContext context, int index, int realIndex) {
                        return FutureBuilder<String>(
                            future: getImageUrl(index),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return Center(child: CupertinoActivityIndicator());
                              }

                              var url = snapshot.data!;

                              return Container(
                                width: MediaQuery.of(context).size.width,
                                height: Get.height* (SizerUtil.orientation == Orientation.landscape ? 2 : 1) *.35,
                                decoration: BoxDecoration(
                                    image: DecorationImage(
                                      fit: BoxFit.cover,
                                      scale: 2,
                                      image: widget.offLine ? FileImage(File(url)) : CachedNetworkImageProvider(url) as ImageProvider,
                                    )),
                              );
                            });
                      },
                    ),
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            alignment: Alignment.center,
                            decoration: BoxDecoration(color: Colors.white.withOpacity(0.3), shape: BoxShape.circle),
                            child: IconButton(
                                onPressed: () => buttonCarouselController.previousPage(duration: Duration(milliseconds: 300), curve: Curves.linear),
                                icon: Icon(
                                  Icons.arrow_back_ios,
                                  color: appPrimaryColor,
                                )),
                          ),
                          Container(
                            alignment: Alignment.center,
                            decoration: BoxDecoration(color: Colors.white.withOpacity(0.3), shape: BoxShape.circle),
                            child: IconButton(
                                onPressed: () => buttonCarouselController.nextPage(duration: Duration(milliseconds: 300), curve: Curves.linear),
                                icon: Icon(
                                  Icons.arrow_forward_ios,
                                  color: appPrimaryColor,
                                )),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
              Container(
                width: MediaQuery.of(context).size.width,
                margin: EdgeInsets.all(10),
                padding: EdgeInsets.only(left: 10,right: 10,top: 10,bottom: 20),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: appBoxShadow),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Description :",
                      style:
                          normal_h1Style_bold.copyWith(color: appPrimaryColor),
                    ),
                    Divider(color: Colors.grey,height: 10,),

                    Text(widget.stop.description),
                  ],
                ),
              ),
              GestureDetector(
                onTap: (){
                  Get.to(ScreenUserPlayStopVideos(stop: widget.stop, offline: widget.offLine));
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10,vertical: 5),
                  margin: EdgeInsets.symmetric(horizontal: 10,vertical: 5),
                  width: MediaQuery.of(context).size.width,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: appBoxShadow),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Stop ${widget.stop.stopVideosUrl.length}  Videos:",
                        style:
                        normal_h1Style_bold.copyWith(color: appPrimaryColor),
                      ),
                      Divider(color: Colors.grey,height: 20,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                        Text("Play Videos",style: normal_h2Style_bold.copyWith(color: appPrimaryColor),),
                        Icon(Icons.arrow_forward_ios,),
                      ],),
                      SizedBox(height: 2.h,),


                    ],
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10,vertical: 5),
                margin: EdgeInsets.symmetric(horizontal: 10,vertical: 5),

                width: MediaQuery.of(context).size.width,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: appBoxShadow),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 2.h,),
                    Text(
                      "Stop ${widget.stop.stopAudiosUrl.length}  Audios:",
                      style: normal_h1Style_bold.copyWith(color: appPrimaryColor),
                    ),
                    Divider(color: Colors.grey,height: 10,),
                    CustomListviewBuilder(
                      itemCount: widget.stop.stopAudiosUrl.length,
                      scrollDirection: CustomDirection.vertical,
                      itemBuilder: (BuildContext context, int index) {
                        return FutureBuilder<String>(
                            future: getAudioUrl(index),
                            builder: (context, audioSnapshot) {
                              if (audioSnapshot.connectionState == ConnectionState.waiting) {
                                return Center(child: CupertinoActivityIndicator());
                              }
                              var url = audioSnapshot.data!;
                              return ItemAudioPlay(
                                url: url,
                              );
                            });
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  Future<String> getImageUrl(int index) async {
    if (!widget.offLine) {
      return widget.stop.stopImagesUrl[index];
    } else {
      var directoryPath = await PermissionUtils.createPathDirectory(".$appName/stops/${widget.stop.id}/images");
      return "$directoryPath/_$index.png";
    }
  }
  Future<String> getAudioUrl(int index) async {
    if (!widget.offLine) {
      return widget.stop.stopAudiosUrl[index];
    } else {
      var directoryPath = await PermissionUtils.createPathDirectory(".$appName/stops/${widget.stop.id}/audios/");
      return "$directoryPath/_$index.mp3";
    }
  }
}
