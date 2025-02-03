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

import 'package:hive/hive.dart';

void addSongsCount(String playlistName, int len, List images) {
  final Map playlistDetails =
  Hive.box('settings').get('playlistDetails', defaultValue: {}) as Map;
  if (playlistDetails.containsKey(playlistName)) {
    playlistDetails[playlistName].addAll({'count': len, 'imagesList': images});
  } else {
    playlistDetails.addEntries([
      MapEntry(playlistName, {'count': len, 'imagesList': images}),
    ]);
  }
  Hive.box('settings').put('playlistDetails', playlistDetails);
}
