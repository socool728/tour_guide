import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:custom_utils/custom_utils.dart';
import 'package:get/get.dart';
import 'package:tour_guide/generated/locales.g.dart';
import 'package:tour_guide/helpers/helpers.dart';
import 'package:tour_guide/views/mobileView/screens/screen_custom_tour.dart';

import '../../../models/tour.dart';
import '../../layouts/item_user_download_tour.dart';
import '../screens/screen_create_custom_stops.dart';

class LayoutUserMobileDownload extends StatefulWidget {
  const LayoutUserMobileDownload({Key? key}) : super(key: key);

  @override
  _LayoutUserMobileDownloadState createState() =>
      _LayoutUserMobileDownloadState();
}

class _LayoutUserMobileDownloadState extends State<LayoutUserMobileDownload> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 1,
        automaticallyImplyLeading: false,
        title: Text(LocaleKeys.DownloadedTour.tr),
        centerTitle: true,
      ),
      body: FutureBuilder<List<Tour>>(
          future: getAllTours(),
          builder: (context, snapshot) {
            if (!snapshot.hasData ||
                snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator.adaptive());
            }
            var tours = snapshot.data ?? [];

            return SingleChildScrollView(
              child: Column(
                children: [
                  (tours.isNotEmpty)
                      ? CustomListviewBuilder(
                          itemBuilder: (BuildContext context, int index) {
                            var tour = tours[index];
                            return

                              ItemUserDownloadTour(
                              tour: tour,
                            );
                          },
                          itemCount: tours.length,
                          scrollDirection: CustomDirection.vertical,
                        )
                      : NotFound(message: "No Data"),
                  SizedBox(height: 20,)
                ],
              ),
            );
          }),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: (){
          Get.to(ScreenCreateCustomStops());
        },
        icon: Icon(Icons.add),
        label: Text("Custom Tour"),
      ),
    );
  }
}
