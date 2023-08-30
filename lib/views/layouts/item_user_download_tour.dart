import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:custom_utils/custom_utils.dart';
import 'package:tour_guide/extensions/num_extensions.dart';
import 'package:tour_guide/generated/locales.g.dart';
import 'package:tour_guide/models/tour.dart';

import '../../helpers/helpers.dart';
import '../mobileView/screens/screen_user_mobile_tour_detail.dart';

class ItemUserDownloadTour extends StatelessWidget {
 Tour tour;
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: appBoxShadow,
        borderRadius: BorderRadius.circular(8),
      ),
      margin: EdgeInsets.all(6.sp),
      padding: EdgeInsets.all(5.sp),
      child: Row(
        children: [
          Expanded(
              flex: 1,
              child: Container(
                height: Get.height* (SizerUtil.orientation == Orientation.landscape ? 2 : 1) * .16,
                decoration: BoxDecoration(
                    image: DecorationImage(
                        fit: BoxFit.fill,
                        image: CachedNetworkImageProvider(tour.imagesUrl.isNotEmpty ? tour.imagesUrl.first : placeholder_url))),
              )),
          Expanded(
              flex: 2,
              child: Padding(
                padding: EdgeInsets.only(left:4.sp),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tour.title,
                      style: normal_h3Style_bold,
                    ),
                    SizedBox(
                      height: 1.h,
                    ),
                    Text(
                      tour.description,
                      style: normal_h5Style,
                      maxLines: 2,
                      overflow:TextOverflow.ellipsis
                    ),
                    SizedBox(
                      height: 1.h,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(4.0),
                              child:
                                  SvgPicture.asset("assets/svgs/distance.svg"),
                            ),
                            Text(
                              "${(tour.total_distance/1000).roundToNum(2)} km",
                              style: normal_h5Style,
                            )
                          ],
                        ),
                        Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: SvgPicture.asset(
                                  "assets/svgs/time_requird.svg"),
                            ),
                            Text(
                              "${tour.total_time} min",
                              style: normal_h5Style,
                            )
                          ],
                        ),
                        Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(4.0),
                              child:
                                  SvgPicture.asset("assets/svgs/location.svg"),
                            ),
                            Text(
                              LocaleKeys.StopsN.tr.replaceAll("000", "${tour.total_stop}"),
                              style: normal_h5Style,
                            )
                          ],
                        ),
                        Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: SvgPicture.asset("assets/svgs/car.svg"),
                            ),
                            Text(
                             tour.source,
                              style: normal_h5Style,
                            )
                          ],
                        ),
                      ],
                    ),
                    Align(
                      alignment: Alignment.center,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(32),
                        onTap: () {
                          Get.to(ScreenUserMobileTourDetail(tour: tour,));
                        },
                        child: Container(
                            width: Get.width * .3,
                            alignment: Alignment.center,
                            padding: EdgeInsets.symmetric(
                              vertical: 4.sp,
                            ),
                            margin: EdgeInsets.symmetric(
                              vertical: 6.sp,
                            ),
                            decoration: BoxDecoration(
                              color: appPrimaryColor,
                              borderRadius: BorderRadius.circular(32),
                            ),
                            child: Text(
                              LocaleKeys.ExploreTour.tr,
                              style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                  fontSize: 10.sp),
                            )),
                      ),
                    )
                  ],
                ),
              ))
        ],
      ),
    );
  }

 ItemUserDownloadTour({
    required this.tour,
  });
}
