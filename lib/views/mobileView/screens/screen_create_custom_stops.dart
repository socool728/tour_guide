import 'package:custom_utils/custom_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tour_guide/helpers/helpers.dart';
import 'package:tour_guide/views/mobileView/layouts/item_custom_stop.dart';
import 'package:tour_guide/views/mobileView/screens/screen_user_mobile_stops_list.dart';

import '../../../models/stop.dart';

class ScreenCreateCustomStops extends StatefulWidget {
  @override
  _ScreenCreateCustomStopsState createState() => _ScreenCreateCustomStopsState();
}

class _ScreenCreateCustomStopsState extends State<ScreenCreateCustomStops> {
  List<Stop> selectedStops = [];
  List<Stop> allStops = [];
  bool loading = true;

  @override
  void initState() {
    getAllStops();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () {
              Get.back();
            },
            icon: Icon(Icons.arrow_back_ios),
          ),
          title: Text(selectedStops.isNotEmpty ? "${selectedStops.length} selected" : "Create Custom Tour"),
          actions: [
            if (selectedStops.length > 1)
              IconButton(
                  onPressed: () {
                    Get.to(ScreenUserMobileStopsList(
                      offline: true,
                      stops: selectedStops,
                      draggable: true,
                    ));
                  },
                  icon: Icon(Icons.check))
          ],
        ),
        body: loading
            ? Center(child: CircularProgressIndicator.adaptive())
            : allStops.isNotEmpty
                ? CustomListviewBuilder(
                    itemCount: allStops.length,
                    scrollDirection: CustomDirection.vertical,
                    itemBuilder: (BuildContext context, int index) {
                      var stop = allStops[index];
                      return ItemCustomStop(
                        stop: stop,
                        onSelected: () {
                          selectedStops.add(stop);
                          setState(() {});
                        },
                        onRemoved: () {
                          selectedStops.remove(stop);
                          setState(() {});
                        },
                      );
                    },
                  )
                : NotFound(message: "No stops added yet"),
      ),
    );
  }

  void getAllStops() async {
    var snapshot = await stopsRef.get();
    loading = true;
    allStops = snapshot.docs.map((e) => Stop.fromMap(e.data() as Map<String, dynamic>)).toList();
    setState(() {
      loading = false;
    });
  }
}
