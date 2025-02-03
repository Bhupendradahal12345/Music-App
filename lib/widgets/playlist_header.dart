

import 'package:shrayesh_patro/extensions/l10n.dart';
import 'package:flutter/material.dart';

class PlaylistHeader extends StatelessWidget {
  PlaylistHeader(
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
    final _primaryColor = Theme.of(context).colorScheme.primary;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        image,
        const SizedBox(width: 10),
        SizedBox(
          width: MediaQuery.of(context).size.width / 2.3,
          child: Column(
            children: [
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: _primaryColor,
                ),
              ),
              const SizedBox(height: 15),
              Text(
                '$songsLength ${context.l10n!.songs}'.toUpperCase(),
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
