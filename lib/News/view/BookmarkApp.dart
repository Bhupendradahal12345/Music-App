import 'package:shrayesh_patro/extensions/l10n.dart';
import 'package:flutter/material.dart';

class BookmarkApp extends StatelessWidget {
  const BookmarkApp({
    super.key,
  });
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n!.saved),
        centerTitle: true,

      ),
    );
  }
}







