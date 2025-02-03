

import 'dart:io';

import 'package:nepali_utils/nepali_utils.dart';
import 'package:shrayesh_patro/Update/adaptive_widgets.dart';
import 'package:shrayesh_patro/Update/check_update.dart';
import 'package:fluent_ui/fluent_ui.dart' as fluent_ui;
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart';

import '../Extra/download_page.dart';






class Update {
  static Future showCenterLoadingModal(BuildContext context, {String? title}) {
    if (Platform.isWindows) {
      return fluent_ui.showDialog(
        context: context,
        builder: (context) {
          return const fluent_ui.ContentDialog(
            title: Text('Checking Update..'),
            content: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [fluent_ui.ProgressRing()],
            ),
          );
        },
      );
    }
    return showDialog(
      context: context,
      useRootNavigator: false,
      builder: (context) {
        return const AlertDialog(
          title: Text('Checking Update..'),
          content: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [CircularProgressIndicator()],
          ),
        );
      },
    );
  }
  static showPlayerOptions(              //popop dilog 1//////
      BuildContext context,
      ) {
    if (Platform.isWindows) {
      return fluent_ui.showDialog(

        context: context,
        useRootNavigator: false,
        barrierDismissible: true,
        builder: (context) => fluent_ui.FluentTheme(
          data: fluent_ui.FluentThemeData(
            brightness: Brightness.dark,
            accentColor: AdaptiveTheme.of(context).primaryColor.toAccentColor(),
          ),
          child: const DownloadPage(page: 'like',),
        ),
        );

    }
    showModalBottomSheet(
      useRootNavigator: false,
      backgroundColor: Colors.transparent,
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      builder: (context) =>  const DownloadPage(page: 'offline',),
    );
  }
  static showPlayerOptionsModal(BuildContext context) {     // pupop dilog 2 //////
    showGeneralDialog(
      context: context,
      barrierLabel: "Barrier",
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: const Duration(milliseconds: 700),
      pageBuilder: (_, __, ___) {
        return Center(
          child: Container(
              height: 570 ,
            width: 350,
            margin: const EdgeInsets.only(top: 200.0),
            decoration: BoxDecoration(color: Colors.transparent, borderRadius: BorderRadius.circular(10)),
              child: const DownloadPage(page: 'offline',)
          ),
        );
      },
      transitionBuilder: (_, anim, __, child) {
        Tween<Offset> tween;
        if (anim.status == AnimationStatus.reverse) {
          tween = Tween(begin: const Offset(-1, 0), end: Offset.zero);
        } else {
          tween = Tween(begin: const Offset(1, 0), end: Offset.zero);
        }

        return SlideTransition(
          position: tween.animate(anim),
          child: FadeTransition(
            opacity: anim,
            child: child,
          ),
        );
      },
    );
  }
  static Future showUpdateDialog(BuildContext context,
      UpdateInfo? updateInfo,) =>
      showDialog(
        context: context,
        useRootNavigator: false,
        builder: (context) {
          return _updateDialog(context, updateInfo);
        },
      );
}
fluent_ui.SizedBox _updateDialog(BuildContext context, UpdateInfo? updateInfo) {
  return SizedBox(
    height: MediaQuery
        .of(context)
        .size
        .height,
    width: MediaQuery
        .of(context)
        .size
        .width,
    child: LayoutBuilder(builder: (context, constraints) {
      if (Platform.isWindows) {
        return fluent_ui.ContentDialog(
          title: Column(
            children: [
              Center(
                child: Text(
                  updateInfo != null
                      ? 'Update Available'
                      : 'Update Info',),),
              if (updateInfo != null)
                Text(
                  NepaliMoment.fromAD(DateTime.parse(updateInfo.publishedAt)),
                  style: TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 17,
                    color: Theme.of(context).colorScheme.secondary,

                  ),
                )
            ],
          ),
          content: updateInfo != null
              ? SizedBox(
            width: constraints.maxWidth,
            height: constraints.maxHeight - 400,
            child: Markdown(
              data: updateInfo.body,
              shrinkWrap: true,
              softLineBreak: true,
              onTapLink: (text, href, title) {
                if (href != null) {
                  launchUrl(
                    Uri.parse(href),
                    mode: LaunchMode.externalApplication,
                  );
                }
              },
            ),
          )
              : const Text('You are already up to date.'),
          actions: [
            if (updateInfo != null)
              AdaptiveButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Cancel'),
              ),
            AdaptiveFilledButton(
              onPressed: () {
                Navigator.pop(context);
                if (updateInfo != null) {
                  launchUrl(Uri.parse(updateInfo.downloadUrl),
                    mode: LaunchMode.externalApplication,);
                }
              },
              child: Text(updateInfo != null ? 'Update' : 'Done'),
            ),
          ],
        );
      }
      return AlertDialog(
        shape: const RoundedRectangleBorder(
          borderRadius:
          BorderRadius.all(Radius.circular(20)),),
        scrollable: true,
        icon: Center(
          child: Container(
            padding: EdgeInsets.zero,
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(16),),
            child: const Icon(
              Icons.update,
              size: 0,
            ),
          ),
        ),

        title: Column(
          children: [
            Text(updateInfo != null ? 'Update Available' : 'Update Info'),
            if (updateInfo != null)
              Text(
                NepaliMoment.fromAD(DateTime.parse(updateInfo.publishedAt)),
                style: TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: 17,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              )
          ],
        ),
        content: updateInfo != null
            ? SizedBox(
          width: 200,
          height: 150,
          child: Markdown(
            data: updateInfo.body,
            shrinkWrap: true,
            softLineBreak: true,
            onTapLink: (text, href, title) {
              if (href != null) {
                launchUrl(Uri.parse(href));
              }
            },
          ),
        )
            : const Center(
          child: Text('You are already up to date.'),
        ),
        actions: [
          if (updateInfo != null)
            AdaptiveButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
          AdaptiveFilledButton(
            onPressed: () {
              Navigator.pop(context);
              if (updateInfo != null) {
                launchUrl(Uri.parse(updateInfo.downloadUrl),
                  mode: LaunchMode.externalApplication,);
              }
            },
            child: Text(
                updateInfo != null ? 'Update' : 'Done',
      style: TextStyle(
      fontWeight: FontWeight.w900,
      fontSize: 18,
      color: Theme.of(context).colorScheme.secondary,


          ),
      )
          )
        ],
      );
    },),
  );
}