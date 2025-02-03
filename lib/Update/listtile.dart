

import 'package:shrayesh_patro/Update/text_styles.dart';
import 'package:flutter/material.dart';




class AdaptiveListTile extends StatelessWidget {

  const AdaptiveListTile({
    super.key,
    this.leading,
    this.title,
    this.subtitle,
    this.trailing,
    this.description,
    this.isThreeLine = false,
    this.dense = false,
    this.contentPadding,
    this.margin,
    this.enabled = true,
    this.onTap,
    this.onLongPress,
    this.onDoubleTap,
    this.onSecondaryTap,
    this.selected = false,
    this.backgroundColor,
  });
  final Widget? leading;
  final Widget? title;
  final Widget? subtitle;
  final Widget? trailing;
  final Widget? description;
  final bool isThreeLine;
  final bool dense;
  final EdgeInsetsGeometry? contentPadding;
  final EdgeInsetsGeometry? margin;
  final bool enabled;
  final GestureTapCallback? onTap;
  final GestureLongPressCallback? onLongPress;
  final GestureLongPressCallback? onDoubleTap;
  final GestureLongPressCallback? onSecondaryTap;
  final bool selected;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final titleStyle = mediumTextStyle(context, bold: false).copyWith(
      fontSize: dense ? 14.0 : 16.0,
    );

    final subtitleStyle = subtitleTextStyle(context).copyWith(
      fontSize: dense ? 12.0 : 14.0,
    );

    final descriptionStyle = smallTextStyle(context).copyWith(
      fontSize: dense ? 12.0 : 14.0,
    );

    return Container(
      margin: margin,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: enabled ? onTap : null,
          onLongPress: enabled ? onLongPress : null,
          onDoubleTap: enabled ? onDoubleTap : null,
          onSecondaryTap: enabled ? onSecondaryTap : null,
          borderRadius: BorderRadius.circular(4),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Container(
              padding: contentPadding ??
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: selected
                    ? theme.colorScheme.primary.withOpacity(0.1)
                    : backgroundColor,
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      if (leading != null) ...[
                        IconTheme(
                            data: Theme.of(context)
                                .iconTheme
                                .copyWith(size: dense ? 24 : 28),
                            child: leading!,),
                        const SizedBox(width: 16),
                      ],
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (title != null) ...[
                              DefaultTextStyle(
                                style: titleStyle,
                                child: title!,
                              ),
                              if (subtitle != null || isThreeLine)
                                SizedBox(height: dense ? 2.0 : 4.0),
                            ],
                            if (subtitle != null || isThreeLine) ...[
                              DefaultTextStyle(
                                style: subtitleStyle,
                                child: subtitle ?? Container(),
                              ),
                            ],
                          ],
                        ),
                      ),
                      if (trailing != null) ...[
                        const SizedBox(width: 16),
                        trailing!,
                      ],
                    ],
                  ),
                  if (subtitle != null || isThreeLine)
                    SizedBox(height: dense ? 2.0 : 4.0),
                  if (description != null) ...[
                    DefaultTextStyle(
                      style: descriptionStyle,
                      child: description!,
                    ),
                  ],
                  if (description != null) const Divider(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
