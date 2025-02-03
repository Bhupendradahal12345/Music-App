import 'package:flutter/material.dart';

class SettingItem {
  SettingItem({
    required this.title,
    this.icon,
    this.hasNavigation = false,
    this.location,
    this.color,
    this.onTap,
    this.trailing,
    this.subtitle,
  });
  String title;
  IconData? icon;
  Color? color = Colors.black;
  bool hasNavigation = false;
  String? location;
  Function(BuildContext context)? onTap;
  Function(BuildContext context)? trailing;
  Function(BuildContext context)? subtitle;
}
