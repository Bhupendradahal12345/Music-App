

import 'package:shrayesh_patro/utilities/common_variables.dart';
import 'package:flutter/material.dart';

class CustomBar extends StatelessWidget {
  CustomBar(
    this.tileName,
    this.tileIcon, {
    this.onTap,
    this.onLongPress,
    this.trailing,
    this.backgroundColor,
    this.iconColor,
    this.textColor,
    super.key,
  });

  final String tileName;
  final IconData tileIcon;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final Widget? trailing;
  final Color? backgroundColor;
  final Color? iconColor;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: commonBarPadding,
      child: Card(
        elevation: 0,
        color: Colors.transparent,
        child: ListTile(
          minTileHeight: 65,
          leading: Icon(
            tileIcon,
            color: iconColor,
          ),
          title: Text(
            tileName,
            style: TextStyle(fontWeight: FontWeight.w600, color: textColor),
          ),
          trailing: trailing,
          onTap: onTap,
          onLongPress: onLongPress,
        ),
      ),
    );
  }
}
