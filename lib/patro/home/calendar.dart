import 'dart:async';
import 'dart:collection';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:shrayesh_patro/screens/search_page.dart';
import 'package:shrayesh_patro/screens/settings_page.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../Downloads/download.dart';
import '../../Update/update_manager.dart';
import '../../main.dart';



class Patro extends StatefulWidget {
  const Patro({super.key});

  @override
  _PatroState createState() =>
      _PatroState();
}

class _PatroState extends State<Patro> {
  final GlobalKey webViewKey = GlobalKey();

  InAppWebViewController? webViewController;
  InAppWebViewSettings settings = InAppWebViewSettings(
    isInspectable: kDebugMode,
    mediaPlaybackRequiresUserGesture: false,
    allowsInlineMediaPlayback: true,
    iframeAllow: 'camera; microphone',
    iframeAllowFullscreen: true,);

  late ContextMenu contextMenu;
  String url = '';
  double progress = 20;
  final urlController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (!isFdroidBuild) {
      unawaited(checkAppUpdates(context));
    }
    unawaited(checkNecessaryPermissions(context));
    contextMenu = ContextMenu(
      menuItems: [
        ContextMenuItem(
          id: 1,
          title: 'Special',
          action: () async {
            if (kDebugMode) {
              print('Menu item Special clicked!');
            }
            if (kDebugMode) {
              print(await webViewController?.getSelectedText());
            }
            await webViewController?.clearFocus();
          },),
      ],
      settings: ContextMenuSettings(),
      onCreateContextMenu: (hitTestResult) async {
        if (kDebugMode) {
          print('onCreateContextMenu');
        }
        if (kDebugMode) {
          print(hitTestResult.extra);
        }
        if (kDebugMode) {
          print(await webViewController?.getSelectedText());
        }
      },
      onHideContextMenu: () {
        if (kDebugMode) {
          print('onHideContextMenu');
        }
      },
      onContextMenuActionItemClicked: (contextMenuItemClicked) async {
        final id = contextMenuItemClicked.id;
        if (kDebugMode) {
          print('onContextMenuActionItemClicked: $id ${contextMenuItemClicked.title}');
        }
      },);


    ![TargetPlatform.iOS, TargetPlatform.android]
        .contains(defaultTargetPlatform)
        ? null
        : PullToRefreshController(
      settings: PullToRefreshSettings(
        color: Colors.blue,
      ),
      onRefresh: () async {
        if (defaultTargetPlatform == TargetPlatform.android) {
          await webViewController?.reload();
        } else if (defaultTargetPlatform == TargetPlatform.iOS ||
            defaultTargetPlatform == TargetPlatform.macOS) {
          await webViewController?.loadUrl(
            urlRequest:
            URLRequest(url: await webViewController?.getUrl()),);
        }
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
        direction: DismissDirection.none,
        background: const ColoredBox(color: Colors.transparent),
    key: const Key('playScreen'),
    onDismissed: (direction) {
    Navigator.pop(context);
    },
      child: SafeArea(
      child: Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text(AppLocalizations.of(context)!.shrayesh),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            padding: const EdgeInsets.only(right: 30),
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsPage()),
              );
            },
          ), //IconButton
        ], //<Widget>[]
        leading: IconButton(
          padding: const EdgeInsets.only(left: 30),
          icon: const Icon(Icons.search, size: 30),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SearchPage()),
            );
          },
        ),

      ), //AppBar
      body: SafeArea(
        child: Column(children: <Widget>[
          Expanded(
            child: Stack(
              children: [
                InAppWebView(
                  key: webViewKey,
                  initialUrlRequest:
                  URLRequest(url: WebUri('https://gayatraphuyal2.github.io/shrayesh-dahal/')),
                  // initialUrlRequest:
                  // URLRequest(url: WebUri(Uri.base.toString().replaceFirst("/#/", "/") + 'page.html')),
                  // initialFile: "assets/index.html",
                  initialUserScripts: UnmodifiableListView<UserScript>([]),
                  initialSettings: settings,
                  contextMenu: contextMenu,

                  onWebViewCreated: (controller) async {
                    webViewController = controller;
                  },
                  onLoadStart: (controller, url) async {
                    setState(() {
                      this.url = url.toString();
                      urlController.text = this.url;
                    });
                  },
                  onPermissionRequest: (controller, request) async {
                    return PermissionResponse(
                        resources: request.resources,
                        action: PermissionResponseAction.GRANT);
                  },
                  shouldOverrideUrlLoading:
                      (controller, navigationAction) async {
                    final uri = navigationAction.request.url!;

                    if (![
                      'http',
                      'https',
                      'file',
                      'chrome',
                      'data',
                      'javascript',
                      'about'
                    ].contains(uri.scheme)) {
                      if (await canLaunchUrl(uri)) {
                        // Launch the App
                        await launchUrl(
                          uri,
                        );
                        // and cancel the request
                        return NavigationActionPolicy.CANCEL;
                      }
                    }

                    return NavigationActionPolicy.ALLOW;
                  },
                  onLoadStop: (controller, url) async {

                    setState(() {
                      this.url = url.toString();
                      urlController.text = this.url;
                    });
                  },
                  onReceivedError: (controller, request, error) {

                  },
                  onProgressChanged: (controller, progress) {
                    if (progress == 100) {

                    }
                    setState(() {
                      this.progress = progress / 100;
                      urlController.text = url;
                    });
                  },
                  onUpdateVisitedHistory: (controller, url, isReload) {
                    setState(() {
                      this.url = url.toString();
                      urlController.text = this.url;
                    });
                  },
                  onConsoleMessage: (controller, consoleMessage) {
                    if (kDebugMode) {
                      print(consoleMessage);
                    }
                  },
                ),
                if (progress < 1.0) LinearProgressIndicator(value: progress) else Container(),
              ],
            ),
          ),



        ],
        ),
    )
      )
      ),);
  }
}
