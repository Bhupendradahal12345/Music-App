/*
 *     Copyright (C) 2024 Valeri Gokadze
 *
 *     Shrayesh-Music is free software: you can redistribute it and/or modify
 *     it under the terms of the GNU General Public License as published by
 *     the Free Software Foundation, either version 3 of the License, or
 *     (at your option) any later version.
 *
 *     Shrayesh-Music is distributed in the hope that it will be useful,
 *     but WITHOUT ANY WARRANTY; without even the implied warranty of
 *     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *     GNU General Public License for more details.
 *
 *     You should have received a copy of the GNU General Public License
 *     along with this program.  If not, see <https://www.gnu.org/licenses/>.
 *
 *
 *     For more information about Shrayesh-Music, including how to contribute,
 *     please visit: https://github.com/bhupendra/Shrayesh-Music
 */

import 'dart:io';

import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shrayesh_patro/API/shrayesh_patro.dart';
import 'package:shrayesh_patro/extensions/l10n.dart';
import 'package:shrayesh_patro/main.dart';
import 'package:shrayesh_patro/services/settings_manager.dart';
import 'package:shrayesh_patro/utilities/common_variables.dart';
import 'package:shrayesh_patro/utilities/flutter_toast.dart';
import 'package:shrayesh_patro/utilities/formatter.dart';
import 'package:shrayesh_patro/widgets/no_artwork_cube.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../Backup/seek_bar.dart';
import '../Update/inkwell.dart';

class SearchDemo extends StatelessWidget {
  SearchDemo(
      this.song,
      this.clearPlaylist, {
        this.backgroundColor,
        this.showMusicDuration = false,
        this.onPlay,
        this.onRemove,
        super.key,
      });

  final dynamic song;
  final bool clearPlaylist;
  final Color? backgroundColor;
  final VoidCallback? onRemove;
  final VoidCallback? onPlay;
  final bool showMusicDuration;

  static const likeStatusToIconMapper = {

  };

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    return Padding(
      padding: commonBarPadding,
      child: AdaptiveInkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onPlay ??
                () {
              audioHandler.playSong(song);
              if (activePlaylist.isNotEmpty && clearPlaylist) {
                activePlaylist = {
                  'ytid': '',
                  'title': 'No Playlist',
                  'image': '',
                  'list': [],
                };
                activeSongId = 0;
              }
            },
        child: Card(
          elevation: 0,
          color: Colors.transparent,
          child: Padding(
            padding: const EdgeInsets.all(2),
            child: Row(
              children: [
                _buildAlbumArt(),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        song['title'],
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: primaryColor,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 0),
                      if (song['author'] != null)
                        Text(
                          song['author'].toString(),
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: 14,

                          ),
                        ),
                      const SizedBox(height: 0),
                      if (song['uploadDateRaw'] != null)
                        Text(
                          song['uploadDateRaw'].toString(),
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: 16,

                          ),
                        ),
                    ],
                  ),
                ),
                _buildActionButtons(context, primaryColor),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAlbumArt() {
    const size = 60.0;
    const radius = 12.0;

    final bool isOffline = song['isOffline'] ?? false;
    final String? artworkPath = song['artworkPath'];
    if (isOffline && artworkPath != null) {
      return SizedBox(
        width: size,
        height: size,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(radius),
          child: Image.file(
            File(artworkPath),
            fit: BoxFit.cover,
          ),
        ),
      );
    } else {
      return CachedNetworkImage(
        key: Key(song['ytid'].toString()),
        width: size,
        height: size,
        imageUrl: song['lowResImage'].toString(),
        imageBuilder: (context, imageProvider) => SizedBox(
          width: size,
          height: size,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(radius),
            child: Image(
              image: imageProvider,
              centerSlice: const Rect.fromLTRB(1, 1, 1, 1),
            ),
          ),
        ),
        errorWidget: (context, url, error) => const NullArtworkWidget(
          iconSize: 30,
        ),
      );
    }
  }

  Widget _buildActionButtons(BuildContext context, Color primaryColor) {
    final songLikeStatus =
    ValueNotifier<bool>(isSongAlreadyLiked(song['ytid']));
    final songOfflineStatus =
    ValueNotifier<bool>(isSongAlreadyOffline(song['ytid']));

    return PopupMenuButton<String>(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      icon: const Icon(
        size: 25,
        Icons.more_vert_rounded,
      ),
      onSelected: (String value) {
        switch (value) {
          case 'like':
            songLikeStatus.value = !songLikeStatus.value;
            updateSongLikeStatus(
              song['ytid'],
              songLikeStatus.value,
            );
            final likedSongsLength = currentLikedSongsLength.value;
            currentLikedSongsLength.value = songLikeStatus.value
                ? likedSongsLength + 1
                : likedSongsLength - 1;
            break;
          case 'offline':
            if (songOfflineStatus.value) {
              removeSongFromOffline(song['ytid']);
            } else {
              makeSongOffline(song);
            }
            songOfflineStatus.value = !songOfflineStatus.value;
            break;
          case 'youtube':
            launchUrl(
              Uri.parse('https://youtube.com/watch?v=${song["ytid"]}'),
              mode: LaunchMode.externalApplication,
            );
            break;
          case 'Share':
            Share.share('https://youtube.com/watch?v=${song["ytid"]}');
        }
      },
      itemBuilder: (BuildContext context) {
        return [
          PopupMenuItem<String>(
            value: 'like',
            child: ValueListenableBuilder<bool>(
              valueListenable: songLikeStatus,
              builder: (_, value, __) {
                return Row(
                  children: [
                    Icon(
                      value ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                      color: value ? Theme.of(context).colorScheme.secondary : Theme.of(context).iconTheme.color,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      value
                          ? context.l10n!.removeFromLikedSongs
                          : context.l10n!.addToLikedSongs,
                    ),
                  ],
                );
              },
            ),
          ),
          PopupMenuItem<String>(
            value: 'offline',
            child: ValueListenableBuilder<bool>(
              valueListenable: songOfflineStatus,
              builder: (_, value, __) {
                return Row(
                  children: [
                    Icon(
                      value ? Icons.download_done_rounded : Icons.download_rounded,
                      color: value ? Theme.of(context).colorScheme.secondary : Theme.of(context).iconTheme.color,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      value
                          ? context.l10n!.removeOffline
                          : context.l10n!.makeOffline,
                    ),
                  ],
                );
              },
            ),
          ),
          PopupMenuItem(
            value: 'youtube',
            child: Row(
              children: [
                const Icon(
                  MdiIcons.youtube,
                ),
                const SizedBox(
                  width: 10.0,
                ),
                Text(
                  context.l10n!
                      .watchVideo,
                ),
              ],
            ),
          ),
          PopupMenuItem(
            value: 'Share',
            child: Row(
              children: [
                const Icon(
                  Icons.share_rounded,
                ),
                const SizedBox(
                  width: 10.0,
                ),
                Text(
                  context.l10n!
                      .share,
                ),
              ],
            ),
          ),
          PopupMenuItem<String>(
            child: Row(
              children: [
                Icon(FluentIcons.clock_12_filled, color: primaryColor),
                const SizedBox(width: 8),
                if (showMusicDuration && song['duration'] != null)
                  Text(formatDuration(song['duration'])),
              ],
            ),
          )
        ];
      },
    );}
}
void showAddToPlaylistDialog(BuildContext context, dynamic song) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        icon: const Icon(FluentIcons.text_bullet_list_add_24_filled),
        title: Text(context.l10n!.addToPlaylist),
        content: Container(
          width: double.maxFinite,
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.6,
          ),
          child: userCustomPlaylists.isNotEmpty
              ? ListView.builder(
            shrinkWrap: true,
            itemCount: userCustomPlaylists.length,
            itemBuilder: (context, index) {
              final playlist = userCustomPlaylists[index];
              return Card(
                color: Theme.of(context).colorScheme.secondaryContainer,
                elevation: 0,
                child: ListTile(
                  title: Text(playlist['title']),
                  onTap: () {
                    addSongInCustomPlaylist(playlist['title'], song);
                    ShowSnackBar().showSnackBar(context, context.l10n!.songAdded);
                    Navigator.pop(context);
                  },
                ),
              );
            },
          )
              : Text(
            context.l10n!.noCustomPlaylists,
            textAlign: TextAlign.center,
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: Text(context.l10n!.cancel),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}
