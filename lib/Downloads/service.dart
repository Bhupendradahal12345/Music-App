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
 * along with Shrayesh_music.  If not, see <http://www.gnu.org/licenses/>.
 *
 * Copyright (c) 2023-2024, Bhupendra Dahal
 */


import 'dart:io';

import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class Services {

  final YoutubeExplode _yt = YoutubeExplode();

  Services._privateConstructor();

  static final Services _instance =
  Services._privateConstructor();

  static Services get instance {
    return _instance;
  }



  Future<List<AudioOnlyStreamInfo>> getStreamInfo(
      String songId, {
        bool onlyMp4 = false,
      }) async {
    final StreamManifest manifest =
    await _yt.videos.streamsClient.getManifest(songId);
    final List<AudioOnlyStreamInfo> sortedStreamInfo = manifest.audioOnly
        .toList()
      ..sort((a, b) => a.bitrate.compareTo(b.bitrate));
    if (onlyMp4 || Platform.isIOS || Platform.isMacOS) {
      final List<AudioOnlyStreamInfo> m4aStreams = sortedStreamInfo
          .where((element) => element.audioCodec.contains('mp4'))
          .toList();

      if (m4aStreams.isNotEmpty) {
        return m4aStreams;
      }
    }

    return sortedStreamInfo;
  }

  Stream<List<int>> getStreamClient(
      AudioOnlyStreamInfo streamInfo,
      ) {
    return _yt.videos.streamsClient.get(streamInfo);
  }
}
