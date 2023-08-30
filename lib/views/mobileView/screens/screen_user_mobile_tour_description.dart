import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:custom_utils/custom_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:read_more_text/read_more_text.dart';
import 'package:tour_guide/generated/locales.g.dart';
import 'package:tour_guide/helpers/permissions_utils.dart';
import 'package:tour_guide/views/mobileView/layouts/item_audio_play.dart';
import 'package:tour_guide/views/mobileView/screens/screen_user_location.dart';

import '../../../helpers/helpers.dart';
import '../../../models/stop.dart';
import '../../../models/tour.dart';

class ScreenUserMobileTourDescription extends StatefulWidget {
  Tour tour;
  bool offline;
  List<Stop> stops;

  @override
  _ScreenUserMobileTourDescriptionState createState() => _ScreenUserMobileTourDescriptionState();

  ScreenUserMobileTourDescription({
    required this.tour,
    required this.stops,
    required this.offline,
  });
}

class _ScreenUserMobileTourDescriptionState extends State<ScreenUserMobileTourDescription> {
  CarouselController buttonCarouselController = CarouselController();
  bool play = false;
  bool silent = false;

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
          title: Text(widget.tour.title),
          // actions: [IconButton(onPressed: () {
          //   Get.to(ScreenUserMobileStopsList());
          // }, icon: Icon(Icons.list))],
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
                    CarouselSlider.builder(
                      itemCount: widget.tour.imagesUrl.length,
                      carouselController: buttonCarouselController,
                      options: CarouselOptions(
                        autoPlay: false,
                        height: Get.height* (SizerUtil.orientation == Orientation.landscape ? 2 : 1) *.35,
                        reverse: false,
                        enlargeCenterPage: true,
                        viewportFraction: 1,
                        aspectRatio: 16 / 9,
                        initialPage: widget.tour.imagesUrl.first.length,
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
                                  image: widget.offline ? FileImage(File(url)) : CachedNetworkImageProvider(url) as ImageProvider,
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
                width: Get.width,
                margin: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                decoration: BoxDecoration(
                  boxShadow: appBoxShadow,
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      LocaleKeys.Description.tr,
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
              CustomListviewBuilder(
                itemCount: widget.tour.audiosUrl.length,
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
              CustomButton(
                  padding: EdgeInsets.symmetric(vertical: 10.sp),
                  width: Get.width * 0.5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(32)),
                  ),
                  // loading: showLoading,
                  text: LocaleKeys.Skip.tr,
                  onPressed: () async {
                    Get.off(ScreenUserLocation(
                      tour: widget.tour,
                      stop: widget.stops,
                      offline: widget.offline,
                    ));
                  })
            ],
          ),
        ),
      ),
    );
  }

  Future<String> getImageUrl(int index) async {
    if (!widget.offline) {
      return widget.tour.imagesUrl[index];
    } else {
      var directoryPath = await PermissionUtils.createPathDirectory(".$appName/tours/${widget.tour.id}/images");
      return "$directoryPath/_$index.png";
    }
  }

  Future<String> getAudioUrl(int index) async {
    if (!widget.offline) {
      return widget.tour.audiosUrl[index];
    } else {
      var directoryPath = await PermissionUtils.createPathDirectory(".$appName/tours/${widget.tour.id}/audios");
      return "$directoryPath/_$index.mp3";
    }
  }
}
