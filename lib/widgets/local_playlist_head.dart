

import 'package:shrayesh_patro/extensions/l10n.dart';
import 'package:flutter/material.dart';

class Head extends StatelessWidget {
  Head(
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
    return Container(

        alignment: Alignment.center,
        padding: const EdgeInsets.only(right: 120.0),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.transparent)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [

            Text(
              '$songsLength ${context.l10n!.songs}'.toLowerCase(),
              textAlign: TextAlign.left,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 17,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),

          ],
        )
    );

  }
}
