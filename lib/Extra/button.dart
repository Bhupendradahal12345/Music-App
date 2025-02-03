


import 'package:flutter/material.dart';

class Button extends StatelessWidget {
  const Button({
    super.key,
    required this.onSecondaryColor,
    required this.onPrimaryColor,
    required this.isLiked,
    required this.onPressed,
  });
  final Color onSecondaryColor;
  final Color onPrimaryColor;
  final bool isLiked;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    const likeStatusToIconMapper = {
      true: Icons.delete_rounded,
      false: Icons.delete_rounded,
    };
    return DecoratedBox(
      decoration: BoxDecoration(
        color: onSecondaryColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(
          likeStatusToIconMapper[isLiked],
          color: Theme.of(context).colorScheme.secondary,
          size: 30,
        ),
      ),
    );
  }
}
