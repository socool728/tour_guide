import 'package:custom_utils/custom_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

class CustomProgressButton extends StatefulWidget {
  final Color? color;
  final String text;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final VoidCallback onPressed;
  final VoidCallback? onLongPressed;
  final TextStyle? textStyle;
  final TextAlign? textAlign;
  final OutlinedBorder? shape;
  final bool? enabled;
  final bool? loading;
  final double? elevation;
  final Color? shadowColor;
  final Duration? animationDuration;
  final ButtonType? buttonType;
  final double? progress;
  final String? progressText;

  CustomProgressButton(
      {this.color,
      required this.text,
      required this.onPressed,
      this.width,
      this.margin,
      this.height,
      this.textStyle,
      this.shape,
      this.padding,
      this.textAlign,
      this.onLongPressed,
      this.enabled,
      this.loading,
      this.elevation,
      this.shadowColor,
      this.buttonType,
      this.progress,
      this.progressText,
      this.animationDuration});

  @override
  _CustomProgressButtonState createState() => _CustomProgressButtonState();
}

class _CustomProgressButtonState extends State<CustomProgressButton> {
  @override
  Widget build(BuildContext context) {
    var buttonType = widget.buttonType ?? ButtonType.clickable;

    return GestureDetector(
      onTap: widget.onPressed,
      child: Container(
        margin: widget.margin ?? const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
        height: widget.height,
        width: widget.width,
        child: buttonType == ButtonType.clickable
            ? ElevatedButton(
                onLongPress: widget.onLongPressed,
                onPressed: ((widget.enabled != null && !widget.enabled!) || (widget.loading != null && widget.loading!)) ? null : widget.onPressed,
                style: ElevatedButton.styleFrom(
                  padding: widget.padding,
                  elevation: widget.elevation,
                  shadowColor: widget.shadowColor,
                  animationDuration: widget.animationDuration,
                  primary: (widget.color ?? buttonColor),
                  shape: widget.shape ??
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                ),
                child: (widget.loading != null && widget.loading == true)
                    ? CupertinoActivityIndicator()
                    : Text(
                        widget.text,
                        textAlign: widget.textAlign ?? TextAlign.center,
                        style: widget.textStyle ?? normal_h3Style.copyWith(color: Colors.white),
                      ),
              )
            : LinearPercentIndicator(
                width: widget.width,
                lineHeight: 25.sp,
                center: Text(
                  widget.progressText ?? "",
                  style: TextStyle(color: (widget.progress ?? 0) > 40 ? Colors.white : Colors.black),
                ),
                percent: (widget.progress ?? 0) / 100,
                barRadius: Radius.circular(10),
                progressColor: appPrimaryColor,
              ),
      ),
    );
  }
}

enum ButtonType { progress, clickable }
