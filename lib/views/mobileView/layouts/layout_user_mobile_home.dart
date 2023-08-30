import 'package:custom_utils/custom_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:tour_guide/generated/locales.g.dart';

import '../../../helpers/helpers.dart';
import '../../../models/tour.dart';
import '../../layouts/item_user_download_tour.dart';

class LayoutUserMobileHome extends StatefulWidget {
  @override
  State<LayoutUserMobileHome> createState() => _LayoutUserMobileHomeState();
  VoidCallback onLanguageTap;

  LayoutUserMobileHome({
    required this.onLanguageTap,
  });
}

class _LayoutUserMobileHomeState extends State<LayoutUserMobileHome> {
  ScrollController? _scrollController;

  bool lastStatus = true;

  double height = 200;

  void _scrollListener() {
    if (_isShrink != lastStatus) {
      setState(() {
        lastStatus = _isShrink;
      });
    }
  }

  bool get _isShrink {
    return _scrollController != null && _scrollController!.hasClients && _scrollController!.offset > (height - kToolbarHeight);
  }

  @override
  void initState() {
    super.initState();
    getTours();
    _scrollController = ScrollController()..addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController?.removeListener(_scrollListener);
    _scrollController?.dispose();
    super.dispose();
  }

  bool loading = true;
  List<Tour> tours = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        controller: _scrollController,
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              automaticallyImplyLeading: false,
              elevation: 1,
              backgroundColor: Colors.white,
              pinned: true,
              expandedHeight: Get.height * (SizerUtil.orientation == Orientation.landscape ? 2 : 1) * .26,
              flexibleSpace: FlexibleSpaceBar(
                centerTitle: true,
                collapseMode: CollapseMode.parallax,
                title: _isShrink
                    ? Text(
                        "$appName",
                        style: normal_h1Style_bold.copyWith(color: Colors.black),
                      )
                    : null,
                background: Container(
                  decoration: BoxDecoration(image: DecorationImage(fit: BoxFit.fill, image: AssetImage("assets/images/home_bg.png"))),
                  child: Stack(
                    // alignment: AlignmentDirectional.center,
                    children: [
                      Positioned.fill(
                          child: Container(
                        color: Color(0xFF4F4F4F).withOpacity(.5),
                      )),
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            RichText(
                              text: TextSpan(text: "MALTA", style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.w500), children: [
                                WidgetSpan(
                                  child: Padding(
                                    padding: EdgeInsets.all(4.0.sp),
                                    child: SvgPicture.asset("assets/svgs/directions_car.svg"),
                                  ),
                                )
                              ]),
                            ),
                            SizedBox(
                              height: 3.h,
                            ),
                            GestureDetector(
                              onTap: () {
                                widget.onLanguageTap();
                              },
                              child: RichText(
                                  text: TextSpan(
                                      text: LocaleKeys.ChooseYour.tr,
                                      style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w500),
                                      children: [
                                    TextSpan(
                                      text: " Language",
                                      style: TextStyle(fontSize: 18.sp, color: appPrimaryColor, fontWeight: FontWeight.w500),
                                    )
                                  ])),
                            ),
                            SizedBox(
                              height: 2.h,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ];
        },
        body: CustomScrollView(
          scrollBehavior: ScrollBehavior(),
          slivers: [
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (BuildContext context, int index) {
                  return ItemUserDownloadTour(
                    tour: tours[index],
                  );
                },
                childCount: tours.length,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void getTours() {
    toursRef.snapshots().listen((event) {
      if (mounted) {
        setState(() {
          tours = event.docs.map((e) => Tour.fromMap(e.data() as Map<String, dynamic>)).toList();
          loading = false;
          print(tours.length);
        });
      }
    });
  }
}
