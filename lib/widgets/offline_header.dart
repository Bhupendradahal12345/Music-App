

import 'package:shrayesh_patro/extensions/l10n.dart';
import 'package:flutter/material.dart';

class OfflineHeader extends StatelessWidget {
  OfflineHeader(
      this.image,
      this.title,
      this.songsLength, {
        super.key,
      });

  final Widget image;
  final String title;
  final int songsLength;

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        image,
        const SizedBox(width: 2),
        SizedBox(
          child: Row(
            children: [
              Text(
                title,
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontSize: 0,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '$songsLength ${context.l10n!.songs}'.toLowerCase(),
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 17,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
