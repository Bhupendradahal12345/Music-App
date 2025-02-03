/*
 *     Copyright (C) 2024 Valeri Gokadze
 *
 *     shrayesh_patro is free software: you can redistribute it and/or modify
 *     it under the terms of the GNU General Public License as published by
 *     the Free Software Foundation, either version 3 of the License, or
 *     (at your option) any later version.
 *
 *     shrayesh_patro is distributed in the hope that it will be useful,
 *     but WITHOUT ANY WARRANTY; without even the implied warranty of
 *     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *     GNU General Public License for more details.
 *
 *     You should have received a copy of the GNU General Public License
 *     along with this program.  If not, see <https://www.gnu.org/licenses/>.
 *
 *
 *     For more information about shrayesh_patro, including how to contribute,
 *     please visit: https://github.com/bhupendra/shrayesh_patro
 */

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:path_provider/path_provider.dart';
import 'package:shrayesh_patro/Backup/ext_storage_provider.dart';
import 'package:shrayesh_patro/DB/albums.db.dart';
import 'package:shrayesh_patro/DB/playlists.db.dart';
import 'package:shrayesh_patro/extensions/l10n.dart';
import 'package:shrayesh_patro/main.dart';
import 'package:shrayesh_patro/services/data_manager.dart';
import 'package:shrayesh_patro/services/lyrics_manager.dart';
import 'package:shrayesh_patro/services/settings_manager.dart';
import 'package:shrayesh_patro/utilities/formatter.dart';
import 'package:flutter/widgets.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

import '../Backup/seek_bar.dart';


final _yt = YoutubeExplode();

List globalSongs = [];

List playlists = [...playlistsDB, ...albumsDB];
List userPlaylists = Hive.box('user').get('playlists', defaultValue: []);
List userCustomPlaylists =
Hive.box('user').get('customPlaylists', defaultValue: []);
List userLikedSongsList = Hive.box('user').get('likedSongs', defaultValue: []);
List userLikedPlaylists =
Hive.box('user').get('likedPlaylists', defaultValue: []);
List userRecentlyPlayed =
Hive.box('user').get('recentlyPlayedSongs', defaultValue: []);
List userOfflineSongs =
Hive.box('userNoBackup').get('offlineSongs', defaultValue: []);
List suggestedPlaylists = [];
List onlinePlaylists = [];
Map activePlaylist = {
  'ytid': '',
  'title': 'No Playlist',
  'image': '',
  'list': [],
};

final currentLikedSongsLength = ValueNotifier<int>(userLikedSongsList.length);
final currentLikedPlaylistsLength =
ValueNotifier<int>(userLikedPlaylists.length);
final currentOfflineSongsLength = ValueNotifier<int>(userOfflineSongs.length);
final currentRecentlyPlayedLength =
ValueNotifier<int>(userRecentlyPlayed.length);

final lyrics = ValueNotifier<String?>(null);
String? lastFetchedLyrics;

int activeSongId = 0;

Future<List> fetchSongsList(String searchQuery) async {
  try {
    final List<Video> searchResults = await _yt.search.search(searchQuery);

    return searchResults.map((video) => returnSongLayout(0, video)).toList();
  } catch (e, stackTrace) {
    logger.log('Error in fetchSongsList', e, stackTrace);
    return [];
  }
}

Future<List> getRecommendedSongs() async {
  try {
    if (defaultRecommendations.value && userRecentlyPlayed.isNotEmpty) {
      final playlistSongs = [];
      for (var i = 0; i < 3; i++) {
        final song = await _yt.videos.get(userRecentlyPlayed[i]['ytid']);
        final relatedSongs = await _yt.videos.getRelatedVideos(song) ?? [];
        playlistSongs
            .addAll(relatedSongs.take(3).map((s) => returnSongLayout(0, s)));
      }
      playlistSongs.shuffle();
      return playlistSongs;
    } else {
      final playlistSongs = [...userLikedSongsList, ...userRecentlyPlayed];

      if (globalSongs.isEmpty) {
        const playlistId = 'PL9bw4S5ePsEFAfCoWq16pRDYD9UwN9UTW';
        globalSongs = await getSongsFromPlaylist(playlistId);
      }

      playlistSongs.addAll(globalSongs.take(10));

      if (userCustomPlaylists.isNotEmpty) {
        for (final userPlaylist in userCustomPlaylists) {
          final _list = userPlaylist['list'] as List;
          _list.shuffle();
          playlistSongs.addAll(_list.take(5));
        }
      }

      playlistSongs.shuffle();

      final seenYtIds = <String>{};
      playlistSongs.removeWhere((song) => !seenYtIds.add(song['ytid']));

      return playlistSongs.take(15).toList();
    }
  } catch (e, stackTrace) {
    logger.log('Error in getRecommendedSongs', e, stackTrace);
    return [];
  }
}

Future<List<dynamic>> getUserPlaylists() async {
  final playlistsByUser = [...userCustomPlaylists];
  for (final playlistID in userPlaylists) {
    try {
      final plist = await _yt.playlists.get(playlistID);
      playlistsByUser.add({
        'ytid': plist.id.toString(),
        'title': plist.title,
        'image': null,
        'list': [],
      });
    } catch (e, stackTrace) {
      playlistsByUser.add({
        'ytid': playlistID.toString(),
        'title': 'Failed playlist',
        'image': null,
        'list': [],
      });
      logger.log(
        'Error occurred while fetching the playlist:',
        e,
        stackTrace,
      );
    }
  }
  return playlistsByUser;
}

Future<String> addUserPlaylist(String playlistId, BuildContext context) async {
  if (playlistId.startsWith('http://') || playlistId.startsWith('https://')) {
    return '${context.l10n!.notYTlist}!';
  } else {
    try {
      await _yt.playlists.get(playlistId);
      userPlaylists.add(playlistId);
      addOrUpdateData('user', 'playlists', userPlaylists);
      return '${context.l10n!.addedSuccess}!';
    } catch (e) {
      return '${context.l10n!.error}!';
    }
  }
}

String createCustomPlaylist(
    String playlistName,
    String? image,
    BuildContext context,
    ) {
  final customPlaylist = {
    'title': playlistName,
    'isCustom': true,
    if (image != null) 'image': image,
    'list': [],
  };
  userCustomPlaylists.add(customPlaylist);
  addOrUpdateData('user', 'customPlaylists', userCustomPlaylists);
  return '${context.l10n!.addedSuccess}!';
}

String addSongInCustomPlaylist(
    String playlistName,
    Map song, {
      int? indexToInsert,
    }) {
  final customPlaylist = userCustomPlaylists.firstWhere(
        (playlist) => playlist['title'] == playlistName,
    orElse: () => null,
  );

  if (customPlaylist != null) {
    final List<dynamic> playlistSongs = customPlaylist['list'];
    indexToInsert != null
        ? playlistSongs.insert(indexToInsert, song)
        : playlistSongs.add(song);
    addOrUpdateData('user', 'customPlaylists', userCustomPlaylists);
    return 'Song added to custom playlist: $playlistName';
  } else {
    return 'Custom playlist not found: $playlistName';
  }
}

void removeSongFromPlaylist(
    Map playlist,
    Map songToRemove, {
      int? removeOneAtIndex,
    }) {
  if (playlist['list'] == null) return;
  final playlistSongs = List<dynamic>.from(playlist['list']);
  removeOneAtIndex != null
      ? playlistSongs.removeAt(removeOneAtIndex)
      : playlistSongs
      .removeWhere((song) => song['ytid'] == songToRemove['ytid']);
  playlist['list'] = playlistSongs;
  if (playlist['isCustom']) {
    addOrUpdateData('user', 'customPlaylists', userCustomPlaylists);
  } else {
    addOrUpdateData('user', 'playlists', userPlaylists);
  }
}

void removeUserPlaylist(String playlistId) {
  userPlaylists.remove(playlistId);
  addOrUpdateData('user', 'playlists', userPlaylists);
}

void removeUserCustomPlaylist(dynamic playlist) {
  userCustomPlaylists.remove(playlist);
  addOrUpdateData('user', 'customPlaylists', userCustomPlaylists);
}

Future<void> updateSongLikeStatus(dynamic songId, bool add) async {
  if (add) {
    userLikedSongsList
        .add(await getSongDetails(userLikedSongsList.length, songId));
  } else {
    userLikedSongsList.removeWhere((song) => song['ytid'] == songId);
  }
  addOrUpdateData('user', 'likedSongs', userLikedSongsList);
}

void moveLikedSong(int oldIndex, int newIndex) {
  final _song = userLikedSongsList[oldIndex];
  userLikedSongsList.removeAt(oldIndex);
  userLikedSongsList.insert(newIndex, _song);
  currentLikedSongsLength.value = userLikedSongsList.length;
  addOrUpdateData('user', 'likedSongs', userLikedSongsList);
}

Future<void> updatePlaylistLikeStatus(
    Map likedPlaylist,
    bool add,
    ) async {
  if (add) {
    userLikedPlaylists.add(likedPlaylist);
  } else {
    userLikedPlaylists
        .removeWhere((playlist) => playlist['ytid'] == likedPlaylist['ytid']);
  }
  addOrUpdateData('user', 'likedPlaylists', userLikedPlaylists);
}

bool isSongAlreadyLiked(songIdToCheck) =>
    userLikedSongsList.any((song) => song['ytid'] == songIdToCheck);

bool isPlaylistAlreadyLiked(playlistIdToCheck) =>
    userLikedPlaylists.any((playlist) => playlist['ytid'] == playlistIdToCheck);

bool isSongAlreadyOffline(songIdToCheck) =>
    userOfflineSongs.any((song) => song['ytid'] == songIdToCheck);

Future<List> getPlaylists({
  String? query,
  int? playlistsNum,
  bool onlyLiked = false,
  String type = 'all',
}) async {
  // Early exit if playlists or suggestedPlaylists is empty
  if (playlists.isEmpty ||
      (playlistsNum == null && query == null && suggestedPlaylists.isEmpty)) {
    return [];
  }

  // Filter playlists based on query and type if only query is specified
  if (query != null && playlistsNum == null) {
    final lowercaseQuery = query.toLowerCase();
    final filteredPlaylists = playlists.where((playlist) {
      final lowercaseTitle = playlist['title'].toLowerCase();
      return lowercaseTitle.contains(lowercaseQuery) &&
          ((type == 'all') ||
              (type == 'album' && playlist['isAlbum'] == true) ||
              (type == 'playlist' && playlist['isAlbum'] != true));
    }).toList();

    final searchResults =
    await _yt.search.searchContent(query, filter: TypeFilters.playlist);

    final existingYtid =
    onlinePlaylists.map((playlist) => playlist['ytid'] as String).toSet();

    final newPlaylists = searchResults
        .whereType<SearchPlaylist>()
        .map((playlist) {
      final playlistMap = {
        'ytid': playlist.id.toString(),
        'title': playlist.title,
        'list': [],
      };

      if (!existingYtid.contains(playlistMap['ytid'])) {
        existingYtid.add(playlistMap['ytid'].toString());
        return playlistMap;
      }
      return null;
    })
        .whereType<Map<String, dynamic>>()
        .toList();

    onlinePlaylists.addAll(newPlaylists);
    filteredPlaylists.addAll(
      onlinePlaylists.where(
            (playlist) => playlist['title'].toLowerCase().contains(lowercaseQuery),
      ),
    );

    return filteredPlaylists;
  }

  // Return a subset of suggested playlists if playlistsNum is specified without a query
  if (playlistsNum != null && query == null) {
    if (suggestedPlaylists.isEmpty) {
      suggestedPlaylists = playlists.toList()..shuffle();
    }
    return suggestedPlaylists.take(playlistsNum).toList();
  }

  // Return userLikedPlaylists if onlyLiked flag is set and no query or playlistsNum is specified
  if (onlyLiked && playlistsNum == null && query == null) {
    return userLikedPlaylists;
  }

  // Filter playlists by type
  if (type != 'all') {
    return playlists
        .where(
          (playlist) =>
      (type == 'album' && playlist['isAlbum'] == true) ||
          (type == 'playlist' && playlist['isAlbum'] != true),
    )
        .toList();
  }

  // Return playlists directly if type is 'all'
  return playlists;
}

Future<List<String>> getSearchSuggestions(String query) async {


  final suggestions = await _yt.search.getQuerySuggestions(query);

  return suggestions;
}

Future<List<Map<String, int>>> getSkipSegments(String id) async {
  try {
    final res = await http.get(
      Uri(
        scheme: 'https',
        host: 'sponsor.ajay.app',
        path: '/api/skipSegments',
        queryParameters: {
          'videoID': id,
          'category': [
            'sponsor',
            'selfpromo',
            'interaction',
            'intro',
            'outro',
            'music_offtopic',
          ],
          'actionType': 'skip',
        },
      ),
    );
    if (res.body != 'Not Found') {
      final data = jsonDecode(res.body);
      final segments = data.map((obj) {
        return Map.castFrom<String, dynamic, String, int>({
          'start': obj['segment'].first.toInt(),
          'end': obj['segment'].last.toInt(),
        });
      }).toList();
      return List.castFrom<dynamic, Map<String, int>>(segments);
    } else {
      return [];
    }
  } catch (e, stack) {
    logger.log('Error in getSkipSegments', e, stack);
    return [];
  }
}

Future<Map> getRandomSong() async {
  if (globalSongs.isEmpty) {
    const playlistId = 'PLQlb0UatjMVYRBsTuIA9RcfJauhhLwwDc';
    globalSongs = await getSongsFromPlaylist(playlistId);
  }

  return globalSongs[Random().nextInt(globalSongs.length)];
}

Future<List> getSongsFromPlaylist(dynamic playlistId) async {
  final songList = await getData('cache', 'playlistSongs$playlistId') ?? [];

  if (songList.isEmpty) {
    await for (final song in _yt.playlists.getVideos(playlistId)) {
      songList.add(returnSongLayout(songList.length, song));
    }

    addOrUpdateData('cache', 'playlistSongs$playlistId', songList);
  }

  return songList;
}

Future updatePlaylistList(
    BuildContext context,
    String playlistId,
    ) async {
  final index = findPlaylistIndexByYtId(playlistId);
  if (index != -1) {
    final songList = [];
    await for (final song in _yt.playlists.getVideos(playlistId)) {
      songList.add(returnSongLayout(songList.length, song));
    }

    playlists[index]['list'] = songList;
    addOrUpdateData('cache', 'playlistSongs$playlistId', songList);
    ShowSnackBar().showSnackBar(context, context.l10n!.playlistUpdated);
  }
  return playlists[index];
}

int findPlaylistIndexByYtId(String ytid) {
  return playlists.indexWhere((playlist) => playlist['ytid'] == ytid);
}

Future<void> setActivePlaylist(Map info) async {
  activePlaylist = info;
  activeSongId = 0;

  await  audioHandler.playSong(activePlaylist['list'][activeSongId]);
}

Future<Map<String, dynamic>?> getPlaylistInfoForWidget(
    dynamic id, {
      bool isArtist = false,
    }) async {
  if (!isArtist) {
    Map<String, dynamic>? playlist =
    playlists.firstWhere((list) => list['ytid'] == id, orElse: () => null);

    if (playlist == null) {
      final usPlaylists = await getUserPlaylists();
      playlist = usPlaylists.firstWhere(
            (list) => list['ytid'] == id,
        orElse: () => null,
      );
    }

    playlist ??= onlinePlaylists.firstWhere(
          (list) => list['ytid'] == id,
      orElse: () => null,
    );

    if (playlist != null && playlist['list'].isEmpty) {
      playlist['list'] = await getSongsFromPlaylist(playlist['ytid']);
      if (!playlists.contains(playlist)) {
        playlists.add(playlist);
      }
    }

    return playlist;
  } else {
    final playlist = <String, dynamic>{
      'title': id,
    };

    playlist['list'] = await fetchSongsList(id);

    return playlist;
  }
}

Future<AudioOnlyStreamInfo> getSongManifest(String songId) async {
  try {
    final manifest = await _yt.videos.streamsClient.getManifest(songId);
    final audioStream = manifest.audioOnly.withHighestBitrate();
    return audioStream;
  } catch (e, stackTrace) {
    logger.log('Error while getting song streaming manifest', e, stackTrace);
    rethrow; // Rethrow the exception to allow the caller to handle it
  }
}

const Duration _cacheDuration = Duration(hours: 6);

Future<String> getSong(String songId, bool isLive) async {
  try {
    final qualitySetting = audioQualitySetting.value;

    final cacheKey = 'song_${songId}_${qualitySetting}_url';

    final cachedUrl = await getData(
      'cache',
      cacheKey,
      cachingDuration: _cacheDuration,
    );

    unawaited(updateRecentlyPlayed(songId));

    if (cachedUrl != null) {
      return cachedUrl;
    } else if (isLive) {
      return await getLiveStreamUrl(songId);
    } else {
      return await getAudioUrl(songId, cacheKey);
    }
  } catch (e, stackTrace) {
    logger.log('Error while getting song streaming URL', e, stackTrace);
    rethrow;
  }
}

Future<String> getLiveStreamUrl(String songId) async {
  final streamInfo =
  await _yt.videos.streamsClient.getHttpLiveStreamUrl(VideoId(songId));
  return streamInfo;
}

Future<String> getAudioUrl(
    String songId,
    String cacheKey,
    ) async {
  final manifest = await _yt.videos.streamsClient.getManifest(songId);
  final audioQuality = selectAudioQuality(manifest.audioOnly.sortByBitrate());
  final audioUrl = audioQuality.url.toString();

  addOrUpdateData('cache', cacheKey, audioUrl);
  return audioUrl;
}

AudioStreamInfo selectAudioQuality(List<AudioStreamInfo> availableSources) {
  final qualitySetting = audioQualitySetting.value;

  if (qualitySetting == 'low') {
    return availableSources.last;
  } else if (qualitySetting == 'medium') {
    return availableSources[availableSources.length ~/ 2];
  } else if (qualitySetting == 'high') {
    return availableSources.first;
  } else {
    return availableSources.withHighestBitrate();
  }
}

Future<Map<String, dynamic>> getSongDetails(
    int songIndex,
    String songId,
    ) async {
  try {
    final song = await _yt.videos.get(songId);
    return returnSongLayout(songIndex, song);
  } catch (e, stackTrace) {
    logger.log('Error while getting song details', e, stackTrace);
    rethrow;
  }
}

Future<String?> getSongLyrics(String artist, String title) async {
  if (lastFetchedLyrics != '$artist - $title') {
    lyrics.value = null;
    final _lyrics = await LyricsManager().fetchLyrics(artist, title);
    if (_lyrics != null) {
      lyrics.value = _lyrics;
    } else {
      lyrics.value = 'not found';
    }

    lastFetchedLyrics = '$artist - $title';
    return _lyrics;
  }

  return lyrics.value;
}

void makeSongOffline(dynamic song) async {
  final dir = await getApplicationSupportDirectory();
  final audioDirPath = '${dir.path}/tracks';
  final artworkDirPath = '${dir.path}/artworks';
  final String ytid = song['ytid'];
  final audioFile = File('$audioDirPath/$ytid.m4a');
  final artworkFile0 = File('$artworkDirPath/$ytid.jpg');

  await Directory(audioDirPath).create(recursive: true);
  await Directory(artworkDirPath).create(recursive: true);

  final audioManifest = await getSongManifest(ytid);
  final stream = _yt.videos.streamsClient.get(audioManifest);
  final fileStream = audioFile.openWrite();
  await stream.pipe(fileStream);
  await fileStream.flush();
  await fileStream.close();

  final artworkFile = await _downloadAndSaveArtworkFile(
    song['highResImage'],
    artworkFile0.path,
  );

  if (artworkFile != null) {
    song['artworkPath'] = artworkFile.path;
    song['highResImage'] = artworkFile.path;
    song['lowResImage'] = artworkFile.path;
  }
  song['path'] = audioFile.path;
  userOfflineSongs.add(song);
  addOrUpdateData('userNoBackup', 'offlineSongs', userOfflineSongs);
}

void removeSongFromOffline(dynamic songId) async {
  final dir = await getApplicationSupportDirectory();
  final audioDirPath = '${dir.path}/tracks';
  final artworkDirPath = '${dir.path}/artworks';
  final audioFile = File('$audioDirPath/$songId.m4a');
  final artworkFile = File('$artworkDirPath/$songId.jpg');

  if (await audioFile.exists()) await audioFile.delete();
  if (await artworkFile.exists()) await artworkFile.delete();

  userOfflineSongs.removeWhere((song) => song['ytid'] == songId);
  addOrUpdateData('userNoBackup', 'offlineSongs', userOfflineSongs);
  currentOfflineSongsLength.value = userOfflineSongs.length;
}


Future<File?> _downloadAndSaveArtworkFile(String url, String filePath) async {
  try {
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final file = File(filePath);
      await file.writeAsBytes(response.bodyBytes);
      return file;
    } else {
      logger.log(
        'Failed to download file. Status code: ${response.statusCode}',
        null,
        null,
      );
    }
  } catch (e, stackTrace) {
    logger.log('Error downloading and saving file', e, stackTrace);
  }

  return null;
}

const recentlyPlayedSongsLimit = 50;

Future<void> updateRecentlyPlayed(dynamic songId) async {
  if (userRecentlyPlayed.length == 1 && userRecentlyPlayed[0]['ytid'] == songId)
    return;
  if (userRecentlyPlayed.length >= recentlyPlayedSongsLimit) {
    userRecentlyPlayed.removeLast();
  }

  userRecentlyPlayed.removeWhere((song) => song['ytid'] == songId);
  currentRecentlyPlayedLength.value = userRecentlyPlayed.length;

  final newSongDetails =
  await getSongDetails(userRecentlyPlayed.length, songId);

  userRecentlyPlayed.insert(0, newSongDetails);
  currentRecentlyPlayedLength.value = userRecentlyPlayed.length;
  addOrUpdateData('user', 'recentlyPlayedSongs', userRecentlyPlayed);
}
