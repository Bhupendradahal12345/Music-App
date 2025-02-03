import 'dart:convert';
import 'dart:io';


import 'package:device_info_plus/device_info_plus.dart';
import 'package:http/http.dart' as http;
import 'package:pub_semver/pub_semver.dart';

import '../API/app_config.dart';



Future<UpdateInfo?> checkUpdate({BaseDeviceInfo? deviceInfo}) async {
  final response = await http.get(appConfig.updateUri,
      headers: {'Accept': 'application/vnd.github+json'},);
  final Map update = jsonDecode(response.body);
  final currentVersion = Version.parse(appConfig.codeName);

  final remoteVersion =
  Version.parse(update['tag_name'].toString().replaceAll('v', ''));

  final comparison = remoteVersion.compareTo(currentVersion);

  if (comparison > 0) {
    if (deviceInfo == null) {
      final deviceInfoPlugin = DeviceInfoPlugin();
      deviceInfo = await deviceInfoPlugin.deviceInfo;
    }

    Map? supportedAsset;
    final List assets = update['assets'];
    if (Platform.isAndroid) {
      final List<String> supportedAbis =
      deviceInfo.data['supportedAbis'].cast<String>();

      for (final supportedAbi in supportedAbis) {
        final supportedAssets = assets
            .where((asset) => asset['name'].contains(supportedAbi))
            .toList();
        if (supportedAssets.isNotEmpty) {
          supportedAsset = supportedAssets.first;
          break;
        }
      }
    } else if (Platform.isWindows) {
      final supportedAssets = assets
          .where(
            (asset) =>
        asset['content_type'] == 'application/x-msdownload' ||
            asset['name'].toString().endsWith('.exe'),
      )
          .toList();
      supportedAsset =
      supportedAssets.isNotEmpty ? supportedAssets.first : null;
    }
    if (supportedAsset == null) return null;
    var downloadCount = 0;
    for (final asset in assets) {
      downloadCount += asset['download_count'] as int;
    }
    return UpdateInfo(
      name: update['name'],
      publishedAt: update['published_at'],
      body: update['body'],
      downloadUrl: supportedAsset['browser_download_url'],
      downloadCount: downloadCount,
    );
  } else {
    return null;
  }
}

class UpdateInfo {
  UpdateInfo({
    required this.name,
    required this.publishedAt,
    required this.body,
    required this.downloadCount,
    required this.downloadUrl,
  });
  String name;
  String publishedAt;
  String body;
  String downloadUrl;
  int downloadCount;
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'publishedAt': publishedAt,
      'body': body,
      'downloadUrl': downloadUrl,
      'downloadCount': downloadCount,
    };
  }
}
