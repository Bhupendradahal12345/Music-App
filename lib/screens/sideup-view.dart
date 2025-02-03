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


import 'dart:ui';

import 'package:shrayesh_patro/API/shrayesh_patro.dart';
import 'package:shrayesh_patro/Extra/slide-upbar.dart';
import 'package:shrayesh_patro/extensions/l10n.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import '../Extra/likebar.dart';
import '../main.dart';





class Sideup_View extends StatefulWidget {
  const Sideup_View({
    super.key,
    required this.page,
  });

  final String page;

  @override
  State<Sideup_View> createState() => _UserSongsPageState();
}

class _UserSongsPageState extends State<Sideup_View> {
  bool isEditEnabled = false;

  @override
  Widget build(BuildContext context) {


    final title = getTitle(widget.page, context);
    final icon = getIcon(widget.page);
    final songsList = getSongsList(widget.page);
    final length = getLength(widget.page);

    return Container(
        decoration: BoxDecoration(
        color: Theme
        .of(context)
        .scaffoldBackgroundColor
        .withAlpha(150),
    ),
    child: ClipRRect(
    child: BackdropFilter(
    filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
    child: SafeArea(
    top: false,
    child: _buildCustomScrollView(title, icon, songsList, length)))));



  }

  Widget _buildCustomScrollView(
      String title,
      IconData icon,
      List songsList,
      ValueNotifier length,
      ) {
    return CustomScrollView(
      slivers: [
        const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.all(10),

          ),
        ),
        buildSongList(title, songsList, length),
      ],
    );
  }


  String getTitle(String page, BuildContext context) {
    return {
      'liked': context.l10n!.likedSongs,
      'offline': context.l10n!.offlineSongs,
      'recents': context.l10n!.recentlyPlayed,
    }[page] ??
        context.l10n!.playlist;
  }

  IconData getIcon(String page) {
    return {
      'liked': FluentIcons.heart_24_regular,
      'offline': FluentIcons.arrow_download_24_regular,
      'recents': FluentIcons.history_24_regular,
    }[page] ??
        FluentIcons.heart_24_regular;
  }

  List getSongsList(String page) {
    return {
      'liked': userLikedSongsList,
      'offline': userOfflineSongs,
      'recents': userRecentlyPlayed,
    }[page] ??
        userLikedSongsList;
  }

  ValueNotifier getLength(String page) {
    return {
      'liked': currentLikedSongsLength,
      'offline': currentOfflineSongsLength,
      'recents': currentRecentlyPlayedLength,
    }[page] ??
        currentLikedSongsLength;
  }
  Widget buildSongList(
      String title,
      List songsList,
      ValueNotifier currentSongsLength,
      ) {
    final _playlist = {
      'ytid': '',
      'title': title,
      'list': songsList,
    };
    return ValueListenableBuilder(
      valueListenable: currentSongsLength,
      builder: (_, value, __) {
        if (title == context.l10n!.likedSongs) {
          return SliverReorderableList(
            itemCount: songsList.length,
            itemBuilder: (context, index) {
              final song = songsList[index];

              return ReorderableDragStartListener(
                enabled: isEditEnabled,
                key: Key(song['ytid'].toString()),
                index: index,
                child: LikedBar(
                  song,
                  true,
                  onPlay: () => {
                    audioHandler.playPlaylistSong(
                      playlist: activePlaylist != _playlist ? _playlist : null,
                      songIndex: index,
                    ),
                  },
                ),
              );
            },
            onReorder: (oldIndex, newIndex) {
              setState(() {
                if (oldIndex < newIndex) {
                  newIndex -= 1;
                }
                moveLikedSong(oldIndex, newIndex);
              });
            },
          );
        } else {
          return SliverList(
            delegate: SliverChildBuilderDelegate(
                  (BuildContext context, int index) {
                final song = songsList[index];
                song['isOffline'] = title == context.l10n!.offlineSongs;
                return SlideUpBar(
                  song,
                  true,
                  onPlay: () => {
                    audioHandler.playPlaylistSong(
                      playlist: activePlaylist != _playlist ? _playlist : null,
                      songIndex: index,
                    ),
                  },
                );
              },
              childCount: songsList.length,
            ),
          );
        }
      },
    );
  }
}
