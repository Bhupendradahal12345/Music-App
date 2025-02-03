import 'package:flutter/material.dart';

class TapGesture extends StatelessWidget {
  final Function()? onTap;
  final Function()? onLongPress;
  final Widget? child;
  final double? radius;
  final Key? tapKey;

  const TapGesture(
      {super.key, this.onTap, this.onLongPress, this.child, this.radius, this.tapKey});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius ?? 0),
      child: Material(
          color: Colors.transparent,
          child: InkWell(
            key: tapKey,
            onTap: onTap,
            onLongPress: onLongPress,
            child: child,
          )),
    );
  }
}