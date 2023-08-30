import 'package:custom_utils/custom_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tour_guide/views/mobileView/layouts/layout_user_mobile_about_us.dart';
import 'package:tour_guide/views/mobileView/layouts/layout_user_mobile_download.dart';
import 'package:tour_guide/views/mobileView/layouts/layout_user_mobile_settings.dart';
import 'package:water_drop_nav_bar/water_drop_nav_bar.dart';

import '../layouts/layout_user_mobile_home.dart';

class ScreenUserMobileHomePage extends StatefulWidget {
  const ScreenUserMobileHomePage({Key? key}) : super(key: key);

  @override
  _ScreenUserMobileHomePageState createState() => _ScreenUserMobileHomePageState();
}

class _ScreenUserMobileHomePageState extends State<ScreenUserMobileHomePage> {
  final Color navigationBarColor = Colors.white;
  int selectedIndex = 0;
  late PageController pageController;

  @override
  void initState() {
    super.initState();
    pageController = PageController(initialPage: selectedIndex);
  }

  @override
  Widget build(BuildContext context) {
    /// [AnnotatedRegion<SystemUiOverlayStyle>] only for android black navigation bar. 3 button navigation control (legacy)

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        systemNavigationBarColor: navigationBarColor,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.grey,
          body: PageView(
            physics: const NeverScrollableScrollPhysics(),
            controller: pageController,
            children: <Widget>[
              LayoutUserMobileHome(
                onLanguageTap: () {
                  setState(() {
                    selectedIndex = 3;
                    pageController.animateToPage(selectedIndex, duration: const Duration(milliseconds: 400), curve: Curves.easeOutQuad);
                  });
                },
              ),
              LayoutUserMobileDownload(),
              LayoutUserMobileAboutUs(),
              LayoutUserMobileSettings(),
            ],
          ),
          bottomNavigationBar: WaterDropNavBar(
            waterDropColor: appPrimaryColor,
            backgroundColor: navigationBarColor,
            bottomPadding: 20,
            onItemSelected: (int index) {
              setState(() {
                selectedIndex = index;
              });
              pageController.animateToPage(selectedIndex, duration: const Duration(milliseconds: 400), curve: Curves.easeOutQuad);
            },
            selectedIndex: selectedIndex,
            barItems: <BarItem>[
              BarItem(
                filledIcon: Icons.home,
                outlinedIcon: Icons.home_outlined,
              ),
              BarItem(filledIcon: Icons.download_rounded, outlinedIcon: Icons.download_outlined),
              BarItem(
                filledIcon: Icons.info,
                outlinedIcon: Icons.info_outlined,
              ),
              BarItem(
                filledIcon: Icons.settings,
                outlinedIcon: Icons.settings_outlined,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
