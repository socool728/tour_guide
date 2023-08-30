import 'package:custom_utils/custom_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tour_guide/helpers/helpers.dart';
import 'package:tour_guide/views/mobileView/screens/screen_user_mobile_home_page.dart';

import '../../../generated/locales.g.dart';

class ScreenUserOnBoarding extends StatefulWidget {
  const ScreenUserOnBoarding({Key? key}) : super(key: key);

  @override
  _ScreenUserOnBoardingState createState() => _ScreenUserOnBoardingState();
}

class _ScreenUserOnBoardingState extends State<ScreenUserOnBoarding> {
  bool isTablet(BuildContext context) => MediaQuery.of(context).size.width >= 600;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: MediaQuery.of(context).size.width,
              height: Get.height * (SizerUtil.orientation == Orientation.landscape ? 2 : 1) * .45,
              decoration: BoxDecoration(image: DecorationImage(fit: BoxFit.cover, image: AssetImage("assets/images/on_board.png"))),
            ),
            SizedBox(
              height: 6.h,
            ),
            RichText(
              text: TextSpan(
                  text: LocaleKeys.EnjoyYour.tr,
                  style: TextStyle(fontSize: 20.sp, color: Colors.black54, fontWeight: FontWeight.w400),
                  children: [
                    TextSpan(
                      text: LocaleKeys.Travel.tr,
                      style: TextStyle(fontSize: 20.sp, color: Colors.black, fontWeight: FontWeight.w700),
                    )
                  ]),
            ),
            SizedBox(
              height: 6.h,
            ),
            Text(
              LocaleKeys.OnBoardText.tr,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14.sp, color: Color(0XFF959595), fontWeight: FontWeight.w400),
            ),
            SizedBox(
              height: 12.h,
            ),
            InkWell(
              borderRadius: BorderRadius.circular(32),
              onTap: () {
                updateFirstOpen();
                Get.offAll(ScreenUserMobileHomePage());
              },
              child: Container(
                  alignment: Alignment.center,
                  width: Get.width * .7,
                  padding: EdgeInsets.symmetric(vertical: 8.sp),
                  decoration: BoxDecoration(
                    color: appPrimaryColor,
                    borderRadius: BorderRadius.circular(32),
                  ),
                  child: Text(
                    LocaleKeys.GetStarted.tr,
                    style: TextStyle(fontWeight: FontWeight.w500, color: Colors.white, fontSize: 16.sp),
                  )),
            )
          ],
        ),
      ),
    );
  }
}
