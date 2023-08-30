import 'package:cached_network_image/cached_network_image.dart';
import 'package:custom_utils/custom_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:timelines/timelines.dart';
import 'package:tour_guide/models/stop.dart';

import '../../helpers/helpers.dart';
import '../../helpers/permissions_utils.dart';
import '../mobileView/screens/scree_user_stop_detail.dart';

class ItemUserStopsList extends StatelessWidget {
  Stop stop;
  Key? key;
  bool offline;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: key,
      onTap: () {
        Get.to(ScreeUserStopDetail(stop: stop,offLine: offline,));
      },
      child: Padding(
        padding: const EdgeInsets.only(left: 4.0),
        child: TimelineTile(
          nodeAlign: TimelineNodeAlign.start,
          node: TimelineNode(
            indicator: DotIndicator(
              color: appPrimaryColor,
            ),
            startConnector: SolidLineConnector(
              color: appPrimaryColor,
            ),
            endConnector: SolidLineConnector(
              color: appPrimaryColor,
            ),
          ),
          contents: Container(
              margin: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
              padding: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
              decoration: BoxDecoration(
                boxShadow: appBoxShadow,
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Container(
                    height: 80.sp,
                    width: 80.sp,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        image: DecorationImage(
                            fit: BoxFit.fill,
                            image: CachedNetworkImageProvider(stop.stopImagesUrl.isNotEmpty ? stop.stopImagesUrl.first : placeholder_url))),
                  ),
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.all(5),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            stop.name,
                            style: normal_h2Style_bold,
                          ),
                          Text(
                            stop.description,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: normal_h4Style.copyWith(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios)
                ],
              )),
        ),
      ),
    );
  }

  ItemUserStopsList({
    required this.stop,
    required this.offline,
    this.key,
  });
  Future<String> getAudioUrl(int index) async {
    if (!offline) {
      return stop.stopAudiosUrl[index];
    } else {
      var directoryPath = await PermissionUtils.createPathDirectory(".$appName/stops/${stop.tour_id}/audios");
      return "$directoryPath/_$index.mp3";
    }
  }

}
