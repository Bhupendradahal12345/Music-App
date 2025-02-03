import 'package:flutter/material.dart';

class TextView extends StatelessWidget {
  final String text;
  final Color? color;
  final TextStyle? textStyle;
  final bool? underline;
  final bool? strikeThrough;
  final double? textSize;
  final bool? capitalise;
  final int? maxlines;
  final TextAlign? textAlign;
  final String? fontFamily;
  final FontWeight? fontWeight;
  final double? lineHeight;
  final FontStyle? fontStyle;
  final double? letterSpacing;
  final TextOverflow ?overflow;
  final EdgeInsets? margin;
  final Function()? onTap;
  const TextView(  {super.key, required this.text,
    this.color,
    this.textStyle,
    this.maxlines,
    this.textAlign,
    this.underline,
    this.textSize,
    this.fontFamily,
    this.fontWeight,
    this.lineHeight,
    this.fontStyle,
    this.strikeThrough,
    this.capitalise,
    this.letterSpacing,
    this.overflow, this.margin, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: margin ?? EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        child: Text(
          capitalise != null && capitalise! ? text.toUpperCase() : text,
          maxLines: maxlines,
          overflow: maxlines != null ? TextOverflow.ellipsis : null,
          textAlign: textAlign,
          style: textStyle,

        ),
      ),
    );
  }
}