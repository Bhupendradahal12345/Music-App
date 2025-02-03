/*
 *     Copyright (C) 2024 Valeri Gokadze
 *
 *     Musify is free software: you can redistribute it and/or modify
 *     it under the terms of the GNU General Public License as published by
 *     the Free Software Foundation, either version 3 of the License, or
 *     (at your option) any later version.
 *
 *     Musify is distributed in the hope that it will be useful,
 *     but WITHOUT ANY WARRANTY; without even the implied warranty of
 *     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *     GNU General Public License for more details.
 *
 *     You should have received a copy of the GNU General Public License
 *     along with this program.  If not, see <https://www.gnu.org/licenses/>.
 *
 *
 *     For more information about Musify, including how to contribute,
 *     please visit: https://github.com/gokadzev/Musify
 */

import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:http/http.dart' as http;
import 'package:shrayesh_patro/extensions/l10n.dart';
import '../API/version.dart';
import '../Backup/snack.dart';


late String dlUrl;
const apiUrl =
    'https://raw.githubusercontent.com/bhupendr1973/update/refs/heads/main/check.json';

Future<void> checkAppUpdates(
    BuildContext context, {
      bool downloadUpdateAutomatically = false,
    }) async {
  final response = await http.get(Uri.parse(apiUrl));
  if (response.statusCode != 200) {
    throw Exception('Failed to fetch app updates');
  }
  final map = json.decode(response.body) as Map<String, dynamic>;
  if (isLatestVersionHigher(appVersion, map['version'].toString())) {
    if (downloadUpdateAutomatically) {
      await downloadAppUpdates();
      ShowSnackBar1().showSnackBar1(
        context,
        '${context.l10n!.appUpdateAvailableAndDownloading}!',
      );

    } else {
      ShowSnackBar1().showSnackBar1(
        context,
        '${context.l10n!.appUpdateIsAvailable}!',
      );
    }
  }
}
Future<void> downloadAppUpdates() async {
  final response = await http.get(Uri.parse(apiUrl));
  if (response.statusCode != 200) {
    throw Exception('Failed to fetch app updates');
  }
  final map = json.decode(response.body) as Map<String, dynamic>;
  final dlUrl = await getCPUArchitecture() == 'aarch64'
      ? map['arm64url'].toString()
      : map['url'].toString();
  final dlPath = await FilePicker.platform.getDirectoryPath();
  final file = File('$dlPath/app-arm64-v8a-release.apk');
  if (await file.exists()) {
    await file.delete();
  }
  await FlutterDownloader.enqueue(
    url: dlUrl,
    savedDir: dlPath!,
    fileName: 'app-arm64-v8a-release.apk',
    showNotification: true,
  );
}

bool isLatestVersionHigher(String appVersion, String latestVersion) {
  final parsedAppVersion = appVersion.split('.');
  final parsedAppLatestVersion = latestVersion.split('.');
  final length = parsedAppVersion.length > parsedAppLatestVersion.length
      ? parsedAppVersion.length
      : parsedAppLatestVersion.length;
  for (var i = 0; i < length; i++) {
    final value1 =
    i < parsedAppVersion.length ? int.parse(parsedAppVersion[i]) : 0;
    final value2 = i < parsedAppLatestVersion.length
        ? int.parse(parsedAppLatestVersion[i])
        : 0;
    if (value2 > value1) {
      return true;
    } else if (value2 < value1) {
      return false;
    }
  }
  return false;
}

Future<String> getCPUArchitecture() async {
  final info = await Process.run('uname', ['-m']);
  final cpu = info.stdout.toString().replaceAll('\n', '');
  return cpu;
}
