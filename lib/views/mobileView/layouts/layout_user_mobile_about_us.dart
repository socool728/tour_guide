import 'package:custom_utils/custom_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:tour_guide/generated/locales.g.dart';
import 'package:tour_guide/helpers/helpers.dart';

class LayoutUserMobileAboutUs extends StatefulWidget {
  const LayoutUserMobileAboutUs({Key? key}) : super(key: key);

  @override
  _LayoutUserMobileAboutUsState createState() => _LayoutUserMobileAboutUsState();
}

class _LayoutUserMobileAboutUsState extends State<LayoutUserMobileAboutUs> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 1,
        automaticallyImplyLeading: false,
        title: Text(LocaleKeys.AboutUs.tr),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: Get.height * (SizerUtil.orientation == Orientation.landscape ? 2 : 1) * .25,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(image: DecorationImage(fit: BoxFit.cover, image: AssetImage("assets/images/about_us.png"))),
              child: Stack(
                children: [
                  Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 40.sp,
                        decoration: BoxDecoration(boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.5),
                            blurRadius: 10,
                          )
                        ]),
                      )),
                  Positioned(
                      bottom: 8.sp,
                      left: 12.sp,
                      child: Text(
                        "$appName",
                        style: normal_h1Style_bold.copyWith(color: Colors.white),
                      ))
                ],
              ),
            ),
            SizedBox(
              height: 20.sp,
            ),
            Container(
              margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              decoration: BoxDecoration(
                boxShadow: appBoxShadow,
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                title: Text(
                  LocaleKeys.BusinessEmail.tr,
                  style: normal_h3Style_bold.copyWith(color: appPrimaryColor),
                ),
                subtitle: Text(
                  "clevmalta@gmail.com",
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              decoration: BoxDecoration(
                boxShadow: appBoxShadow,
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                title: Text(
                  "${LocaleKeys.ContactNo.tr}:",
                  style: normal_h3Style_bold.copyWith(color: appPrimaryColor),
                ),
                subtitle: Text(
                  "+35677142418",
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              decoration: BoxDecoration(
                boxShadow: appBoxShadow,
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                title: Text(
                  LocaleKeys.Location.tr,
                  style: normal_h3Style_bold.copyWith(color: appPrimaryColor),
                ),
                subtitle: Text(
                  "MALTA",
                ),
              ),
            ),
            SizedBox(
              height: 3.h,
            ),
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.center,
            //   children: <Widget>[
            //     Padding(
            //       padding: const EdgeInsets.all(8.0),
            //       child: SvgPicture.asset("assets/svgs/share.svg"),
            //     ),
            //     Padding(
            //       padding: const EdgeInsets.all(8.0),
            //       child: SvgPicture.asset("assets/svgs/faceBook.svg"),
            //     ),
            //     Padding(
            //       padding: const EdgeInsets.all(8.0),
            //       child: SvgPicture.asset("assets/svgs/instagram.svg"),
            //     ),
            //     Padding(
            //       padding: const EdgeInsets.all(8.0),
            //       child: SvgPicture.asset("assets/svgs/whatsApp.svg"),
            //     ),
            //     Padding(
            //       padding: const EdgeInsets.all(8.0),
            //       child: SvgPicture.asset("assets/svgs/tiwiter.svg"),
            //     ),
            //   ],
            // ),
          ],
        ),
      ),
    );
  }
}
