import 'package:custom_utils/custom_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:tour_guide/extensions/cap_extension.dart';
import 'package:tour_guide/generated/locales.g.dart';

import '../../../helpers/helpers.dart';

class LayoutUserMobileSettings extends StatefulWidget {
  const LayoutUserMobileSettings({Key? key}) : super(key: key);

  @override
  _LayoutUserMobileSettingsState createState() => _LayoutUserMobileSettingsState();
}

class _LayoutUserMobileSettingsState extends State<LayoutUserMobileSettings> {
  var selectLanguage = LocaleKeys.English;
  final categoryList = [
    LocaleKeys.English,
    LocaleKeys.Urdu,
    LocaleKeys.French,
    LocaleKeys.Russian,
    LocaleKeys.Arabic,
    LocaleKeys.Italian,
  ];
  @override
  void initState() {
    selectLanguage = Get.locale!.languageCode.toLanguage;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 1,
        automaticallyImplyLeading: false,
        title: Text(LocaleKeys.Setting.tr),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 3.sp),
              decoration: BoxDecoration(
                boxShadow: appBoxShadow,
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: DropdownButton<String>(
                  dropdownColor: Colors.white,
                  underline: SizedBox(),
                  icon: Icon(Icons.arrow_drop_down_sharp, color: appPrimaryColor),
                  elevation: 8,
                  iconSize: 30,
                  style: normal_h2Style.copyWith(color: appPrimaryColor),
                  value: selectLanguage,
                  isExpanded: true,
                  items: categoryList.map(selectCategoryMenuItem).toList(),
                  onChanged: (String? selected) {
                    selectLanguage = selected!;
                    Get.updateLocale(Locale(selectLanguage.toCode, selectLanguage.toCode.toUpperCase()));
                    setState(() {});
                  }),
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
                  LocaleKeys.Version.tr,
                  style: normal_h2Style.copyWith(color: appPrimaryColor),
                ),
                trailing: Text(appVersion, style: normal_h3Style.copyWith(color: appPrimaryColor)),
              ),
            ),
            SizedBox(
              height: 40.sp,
            ),
            InkWell(
              borderRadius: BorderRadius.circular(32),
              onTap: () {},
              child: Container(
                alignment: Alignment.center,
                width: Get.width * .7,
                padding: EdgeInsets.symmetric(vertical: 8.sp),
                decoration: BoxDecoration(
                  color: appPrimaryColor,
                  borderRadius: BorderRadius.circular(32),
                ),
                child: Text(
                  LocaleKeys.CheckUpdates.tr,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                    fontSize: 16.sp,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  DropdownMenuItem<String> selectCategoryMenuItem(String item) => DropdownMenuItem(
        value: item,
        child: Text(
          item.tr,
          style: normal_h2Style.copyWith(color: appPrimaryColor),
        ),
      );



}
