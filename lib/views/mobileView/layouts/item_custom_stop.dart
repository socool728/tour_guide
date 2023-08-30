import 'package:cached_network_image/cached_network_image.dart';
import 'package:custom_utils/custom_utils.dart';
import 'package:flutter/material.dart';
import 'package:tour_guide/models/stop.dart';

import '../../../helpers/helpers.dart';

class ItemCustomStop extends StatefulWidget {
  Stop stop;
  Function onSelected;
  Function onRemoved;

  @override
  State<ItemCustomStop> createState() => _ItemCustomStopState();

  ItemCustomStop({
    required this.stop,
    required this.onSelected,
    required this.onRemoved,
  });
}

class _ItemCustomStopState extends State<ItemCustomStop> {
  bool isChecked = false;

  @override
  Widget build(BuildContext context) {
    return Container(
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
                      image: CachedNetworkImageProvider(widget.stop.stopImagesUrl.isNotEmpty ? widget.stop.stopImagesUrl.first : placeholder_url))),
            ),
            Expanded(
              child: Container(
                padding: EdgeInsets.all(5),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.stop.name,
                      style: normal_h2Style_bold,
                    ),
                    Text(
                      widget.stop.description,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: normal_h4Style.copyWith(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
            Checkbox(
                value: isChecked,
                onChanged: (value) {
                  setState(() {
                    isChecked = value!;
                    if (isChecked) {
                      widget.onSelected();
                    } else {
                      widget.onRemoved();
                    }
                  });
                })
          ],
        ));
  }
}
