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


import 'dart:io';
import 'dart:ui';

import 'package:audio_service/audio_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';
import 'package:shrayesh_patro/API/shrayesh_patro.dart';
import 'package:shrayesh_patro/Extra/slide-upbar.dart';
import 'package:shrayesh_patro/extensions/l10n.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import '../Backup/config.dart';
import '../Backup/dominant_color.dart';
import '../Extra/likebar.dart';
import '../main.dart';





class DownloadPage extends StatefulWidget {
  const DownloadPage({
    super.key,
    required this.page,
  });

  final String page;

  @override
  State<DownloadPage> createState() => _UserSongsPageState();
}

class _UserSongsPageState extends State<DownloadPage> {
  bool isEditEnabled = false;
  final String gradientType = Hive.box('settings')
      .get('gradientType', defaultValue: 'halfDark')
      .toString();
  final bool getLyricsOnline =
  Hive.box('settings').get('getLyricsOnline', defaultValue: true) as bool;
  final MyTheme currentTheme = GetIt.I<MyTheme>();
  final ValueNotifier<List<Color?>?> gradientColor =
  ValueNotifier<List<Color?>?>(GetIt
      .I<MyTheme>()
      .playGradientColor);

  void updateBackgroundColors(List<Color?> value) {
    gradientColor.value = value;
    return;
  }

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
              .withAlpha(50),
        ),
        child: ClipRRect(
            child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
                child: StreamBuilder<MediaItem?>(
                    stream: audioHandler.mediaItem,
                    builder: (context, snapshot) {
                      final MediaItem? mediaItem = snapshot.data;
                      if (mediaItem == null) return const SizedBox();
                      if (mediaItem.artUri != null &&
                          mediaItem.artUri.toString() != '') {
                        mediaItem.artUri.toString().startsWith('file')
                            ? getColors(
                          imageProvider: FileImage(
                            File(
                              mediaItem.artUri!.toFilePath(),
                            ),
                          ),

                        ).then((value) => updateBackgroundColors(value))
                            : getColors(
                          imageProvider: CachedNetworkImageProvider(
                            mediaItem.artUri.toString(),
                          ),
                        ).then((value) => updateBackgroundColors(value));
                      }
                      return ValueListenableBuilder(
                        valueListenable: gradientColor,
                        child: SafeArea(
                            top: false,
                            child: _buildCustomScrollView(
                                title, icon, songsList, length)
                        ),
                        builder: (BuildContext context, List<Color?>? value,
                            Widget? child) {
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 600),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: gradientType == 'simple'
                                    ? Alignment.topLeft
                                    : Alignment.topCenter,
                                end: gradientType == 'simple'
                                    ? Alignment.bottomRight
                                    : (gradientType == 'halfLight' ||
                                    gradientType == 'halfDark')
                                    ? Alignment.center
                                    : Alignment.bottomCenter,
                                colors: gradientType == 'simple'
                                    ? Theme
                                    .of(context)
                                    .brightness == Brightness.dark
                                    ? currentTheme.getBackGradient()
                                    : [
                                  const Color(0xfff5f9ff),
                                  Colors.white,
                                ]
                                    : Theme
                                    .of(context)
                                    .brightness == Brightness.dark
                                    ? [
                                  // Top part
                                  if (gradientType == 'halfDark' ||
                                      gradientType == 'fullDark' ||
                                      gradientType == 'fullDarkOnly')
                                    value?[1] ?? Colors.grey[900]!
                                  else
                                    value?[0] ?? Colors.grey[900]!,
                                  // Bottom part
                                  if (gradientType == 'fullMix' ||
                                      gradientType == 'fullMixDarker' ||
                                      gradientType == 'fullMixBlack' ||
                                      gradientType == 'fullDarkOnly')
                                    value?[1] ?? Colors.black
                                  else
                                    Colors.black,
                                  // Extra bottom part incase of full darker and black
                                  if (gradientType == 'fullMixDarker')
                                    value?[1] ?? Colors.black,
                                  if (gradientType == 'fullMixBlack')
                                    Colors.black,
                                ]
                                    : [
                                  value?[0] ?? const Color(0xfff5f9ff),
                                  Colors.white,
                                ],
                              ),
                            ),
                            child: child,
                          );
                        },
                      );
                    }
                )
            )
        )
    );
  }


  Widget _buildCustomScrollView(String title,
      IconData icon,
      List songsList,
      ValueNotifier length,) {
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

  Widget buildSongList(String title,
      List songsList,
      ValueNotifier currentSongsLength,) {
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
                  onPlay: () =>
                  {
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
                  onPlay: () =>
                  {
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

