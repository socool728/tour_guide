import 'package:custom_utils/custom_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tour_guide/generated/locales.g.dart';

class ItemUserTourAudio extends StatefulWidget {
  @override
  State<ItemUserTourAudio> createState() => _ItemUserTourAudioState();
}

class _ItemUserTourAudioState extends State<ItemUserTourAudio> {
  double value = 50;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10,horizontal: 10),
      padding: EdgeInsets.all(5),
      decoration: BoxDecoration(
        boxShadow: appBoxShadow,
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(children: [
        Row(
          children: [
            Container(
              height: 50.sp,
              width: 50.sp,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                image: DecorationImage(
                  image: AssetImage("assets/images/video_thunmb.png")
                )
              ),

            ),
            Padding(
              padding: EdgeInsets.all(5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(LocaleKeys.StopsN.tr.replaceAll("000", "1"),style: normal_h2Style_bold,),
                    Text("Tour Name",style: normal_h4Style_bold.copyWith(color: Colors.grey)),
                    Row(children: [
                      Slider(
                          min: 10,
                          max: 100,
                          value: value,
                          onChanged: (value) {
                            setState(() {
                              value = value;
                            });
                          }),
                      IconButton(onPressed: (){}, icon: Icon(Icons.mic,color: appPrimaryColor,)),

                    ],)
                  ],
                ),
            ),
            ],
        )
      ],),
    );
  }
}
