/*
 *  This file is part of Shrayesh-Music (https://bhupendra12345678.github.io/mymusic/).
 *
 * Shrayesh-Music is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * Shrayesh-Music is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with Shrayesh-Music.  If not, see <http://www.gnu.org/licenses/>.
 *
 * Copyright (c) 2023-2024, Bhupendra Dahal
 */

import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

// ignore: avoid_classes_with_only_static_members
class ExtStorageProvider {
  // asking for permission
  static Future<bool> requestPermission(Permission permission) async {
    if (await permission.isGranted) {
      return true;
    } else {
      final result = await Permission.manageExternalStorage.request();
      if (result == PermissionStatus.granted) {
        return true;
      } else {
        return false;
      }
    }
  }

  // getting external storage path
  static Future<String?> getExtStorage({
    required String dirName,
    required bool writeAccess,
  }) async {
    Directory? directory;

    try {
      // checking platform
      if (Platform.isAndroid) {
        if (await requestPermission(Permission.storage)) {
          directory = await getExternalStorageDirectory();

          // getting main path
          final String newPath = directory!.path
              .replaceFirst('Android/data/com.shrayesh_dahal.patro/files', dirName);

          directory = Directory(newPath);

          // checking if directory exist or not
          if (!await directory.exists()) {
            // if directory not exists then asking for permission to create folder
            await await Permission.manageExternalStorage.request();
            //creating folder

            await directory.create(recursive: true);
          }
          if (await directory.exists()) {
            try {
              if (writeAccess) {
                await await Permission.manageExternalStorage.request();
              }
              // if directory exists then returning the complete path
              return newPath;
            } catch (e) {
              rethrow;
            }
          }
        } else {
          return throw 'something went wrong';
        }
      } else if (Platform.isIOS || Platform.isMacOS) {
        directory = await getApplicationDocumentsDirectory();
        final finalDirName = dirName.replaceAll('Shrayesh-Patro/', '');
        return '${directory.path}/$finalDirName';
      } else {
        directory = await getDownloadsDirectory();
        return '${directory!.path}/$dirName';
      }
    } catch (e) {
      rethrow;
    }
    return directory.path;
  }
}
