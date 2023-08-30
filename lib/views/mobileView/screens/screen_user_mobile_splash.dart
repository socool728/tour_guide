import 'package:custom_utils/custom_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tour_guide/generated/locales.g.dart';
import 'package:tour_guide/views/mobileView/screens/screen_user_mobile_on_boarding.dart';

class ScreenUserMobileSplash extends StatelessWidget {
  const ScreenUserMobileSplash({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: Get.height,
        width: Get.width,
        decoration: BoxDecoration(image: DecorationImage(fit: BoxFit.cover, image: AssetImage("assets/images/splash.png"))),
        child: Stack(
          alignment: AlignmentDirectional.center,
          children: [
            Positioned.fill(
                child: Container(
              color: Colors.black.withOpacity(0.8),
            )),
            Center(
              child: GestureDetector(
                onTap: () {

                  Get.to(ScreenUserOnBoarding());
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "App Logo",
                      style: heading1_style.copyWith(color: Colors.white, fontSize: 37),
                    ),
                    Text(
                      LocaleKeys.ExploreDestination.tr,
                      style: heading1_style.copyWith(color: Colors.white, fontSize: 28),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
