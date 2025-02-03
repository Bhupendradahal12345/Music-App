/*
 *     Copyright (C) 2024 Valeri Gokadze
 *
 *     Shrayesh-Music is free software: you can redistribute it and/or modify
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
import 'package:logging/logging.dart';
import 'package:audiotagger/audiotagger.dart';
import 'package:audiotagger/models/tag.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shrayesh_patro/API/shrayesh_patro.dart';
import 'package:shrayesh_patro/extensions/l10n.dart';
import 'package:shrayesh_patro/main.dart';
import 'package:shrayesh_patro/services/settings_manager.dart';
import 'package:shrayesh_patro/utilities/common_variables.dart';

import 'package:shrayesh_patro/widgets/no_artwork_cube.dart';
import 'package:url_launcher/url_launcher.dart';

import '../Backup/picker.dart';
import '../Backup/seek_bar.dart';
import '../Update/inkwell.dart';
import '../utilities/formatter.dart';



class UserBar extends StatelessWidget {
  const UserBar(
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

                        selectionColor: Theme.of(context).colorScheme.secondary == Colors.white
                            ? Colors.black
                            : Colors.white,
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold
                        ),
                      ),

                      const SizedBox(height: 5),
                      Text(
                        song['artist'].toString(),
                        overflow: TextOverflow.ellipsis,

                        selectionColor: Theme.of(context).colorScheme.secondary == Colors.white
                            ? Colors.black
                            : Colors.white,
                        style: const TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 14,
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
  Future<Map> editTags(Map song, BuildContext context) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        final tagger = Audiotagger();

        FileImage songImage = FileImage(File(song['highResImage'].toString()));

        final titlecontroller =
        TextEditingController(text: song['title'].toString());
        final albumcontroller =
        TextEditingController(text: song['author'].toString());
        final artistcontroller =
        TextEditingController(text: song['artist'].toString());


        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          content: SizedBox(
            height: 200,
            width: 300,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: () async {
                      final String filePath = await Picker.selectFile(
                        context: context,
                        // ext: ['png', 'jpg', 'jpeg'],
                        message: 'Pick Image',
                      );
                      if (filePath != '') {
                        final imagePath = filePath;
                        File(imagePath).copy(song['image'].toString());

                        songImage = FileImage(File(imagePath));

                        final Tag tag = Tag(
                          artwork: imagePath,
                        );
                        try {
                          await [
                            Permission.manageExternalStorage,
                          ].request();
                          await tagger.writeTags(
                            path: song['tracks'].toString(),
                            tag: tag,
                          );
                        } catch (e) {
                          await tagger.writeTags(
                            path: song['tracks'].toString(),
                            tag: tag,
                          );
                        }
                      }
                    },
                    child: Card(
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(7.0),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: SizedBox(
                        height: MediaQuery.sizeOf(context).width / 2,
                        width: MediaQuery.sizeOf(context).width / 2,
                        child: Image(
                          fit: BoxFit.cover,
                          image: songImage,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20.0),
                  Row(
                    children: [
                      Text(
                        context.l10n!.title,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                    ],
                  ),
                  TextField(
                    autofocus: true,
                    controller: titlecontroller,
                    onSubmitted: (value) {},
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  Row(
                    children: [
                      Text(
                        context.l10n!.artist,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                    ],
                  ),
                  TextField(
                    autofocus: true,
                    controller: artistcontroller,
                    onSubmitted: (value) {},
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  Row(
                    children: [
                      Text(
                        context.l10n!.stats,
                        style: TextStyle(
                          fontSize: 0,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                    ],
                  ),



                ],
              ),


            ),

          ),


          actions: [
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : Colors.grey[700],
              ),
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(context.l10n!.cancel),
            ),
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Theme.of(context).colorScheme.secondary,
              ),
              onPressed: () async {
                Navigator.pop(context);
                song['title'] = titlecontroller.text;
                song['author'] = albumcontroller.text;
                song['artist'] = artistcontroller.text;

                final tag = Tag(
                  title: titlecontroller.text,
                  artist: artistcontroller.text,
                  album: albumcontroller.text,

                );
                try {
                  try {
                    await [
                      Permission.manageExternalStorage,
                    ].request();
                    tagger.writeTags(
                      path: song['tracks'].toString(),
                      tag: tag,
                    );
                  } catch (e) {
                    await tagger.writeTags(
                      path: song['tracks'].toString(),
                      tag: tag,
                    );
                    ShowSnackBar().showSnackBar(
                      context,
                      context.l10n!.successTagEdit,
                    );
                  }
                } catch (e) {
                  Logger.root.severe('Failed to edit tags', e);
                  ShowSnackBar().showSnackBar(
                    context,
                    '${context.l10n!.failedTagEdit}\nError: $e',
                  );
                }
              },
              child: Text(
                context.l10n!.ok,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.secondary == Colors.white
                      ? Colors.black
                      : null,
                ),
              ),
            ),
            const SizedBox(
              width: 5,
            ),
          ],
        );
      },
    );
    return song;
  }
  Widget _buildActionButtons(BuildContext context, Color primaryColor) {
    final songOfflineStatus =
    ValueNotifier<bool>(isSongAlreadyOffline(song['ytid']));

    return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!offlineMode.value)
            Row(
              children: [
                ValueListenableBuilder<bool>(
                    valueListenable: songOfflineStatus,
                    builder: (_, value, __) {
                      return PopupMenuButton(
                        icon: const Icon(
                          size: 25,
                          Icons.more_vert_rounded,

                        ),
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(15.0),
                          ),
                        ),
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: 0,
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.playlist_add_rounded,
                                ),
                                const SizedBox(
                                  width: 10.0,
                                ),
                                Text(
                                  context.l10n!
                                      .playlist,
                                ),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 1,
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
                            value: 2,
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

                          PopupMenuItem(
                            value: 3,
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.edit_rounded,
                                ),
                                const SizedBox(
                                  width: 10.0,
                                ),
                                Text(
                                  context.l10n!
                                      .edit,
                                ),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 4,
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.delete_rounded,
                                ),
                                const SizedBox(
                                  width: 10.0,
                                ),
                                Text(
                                  context.l10n!
                                      .delete,
                                ),
                              ],
                            ),
                          ),
                        ],
                        onSelected: (int? value) async {
                          if (value == 0) {
                            showAddToPlaylistDialog(context, song);
                          }
                          if (value == 1) {
                            launchUrl(
                                Uri.parse('https://youtube.com/watch?v=${song["ytid"]}'),
                                mode: LaunchMode.externalApplication);

                          }
                          if (value == 2) {
                            Share.share('https://youtube.com/watch?v=${song["ytid"]}');
                          }

                          if (value == 3) {
                            editTags(
                              song as Map,
                              context,
                            );
                          }
                          if (value == 4) {
                            removeSongFromOffline(song['ytid']);
                          }
                          songOfflineStatus.value = !songOfflineStatus.value;
                        },
                      );
                    }
                )
              ],
            )
        ]
    );
  }
}


void showAddToPlaylistDialog(BuildContext context, dynamic song) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        shape:RoundedRectangleBorder(
            borderRadius:BorderRadius.circular(15.0,)),
        title: Center(child: Text(context.l10n!.addToPlaylist)),
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
                color: Colors.transparent,
                elevation: 0,
                child: ListTile(
                  leading: const Icon(Icons.add),
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
            child: Text(context.l10n!.createPlaylist),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  var id = '';
                  var customPlaylistName = '';
                  String? imageUrl;
                  bool? isYouTubeMode;
                  return StatefulBuilder(
                    builder: (context, setState) {
                      return AlertDialog(
                        shape:RoundedRectangleBorder(
                            borderRadius:BorderRadius.circular(10.0,)),
                        backgroundColor: Theme.of(context).dialogBackgroundColor,
                        content: SingleChildScrollView(
                          child: Column(
                            children: <Widget>[
                              if (isYouTubeMode == true || isYouTubeMode == null)
                                TextField(
                                  decoration: InputDecoration(

                                    icon: const Icon(MdiIcons.youtube),
                                    labelText: context.l10n!.youtubePlaylistID,

                                  ),
                                  onChanged: (value) {
                                    setState(() {
                                      id = value;
                                      if (id.isNotEmpty) {
                                        customPlaylistName = '';
                                        imageUrl = null;
                                        isYouTubeMode = true;
                                      } else {
                                        isYouTubeMode = null;
                                      }
                                    });

                                  },
                                ),
                              const SizedBox(height: 7),
                              if (isYouTubeMode == false ||
                                  isYouTubeMode == null) ...[
                                TextField(
                                  decoration: InputDecoration(
                                    icon: const Icon(Icons.playlist_add_rounded),
                                    labelText: context.l10n!.customPlaylistName,
                                  ),
                                  onChanged: (value) {
                                    setState(() {
                                      customPlaylistName = value;
                                      if (customPlaylistName.isNotEmpty) {
                                        id = '';
                                        isYouTubeMode = false;
                                      } else {
                                        isYouTubeMode = null;
                                      }
                                    });
                                  },
                                ),
                                const SizedBox(height: 7),
                                TextField(
                                  decoration: InputDecoration(
                                    icon: const Icon(Icons.image),
                                    labelText: context.l10n!.customPlaylistImgUrl,
                                  ),
                                  onChanged: (value) {
                                    setState(() {
                                      imageUrl = value;
                                      if (imageUrl!.isNotEmpty) {
                                        id = '';
                                        isYouTubeMode = false;
                                      } else {
                                        isYouTubeMode = null;
                                      }
                                    });
                                  },
                                ),
                              ],
                            ],
                          ),
                        ),
                        actions: <Widget>[
                          TextButton(
                            child: Text(
                              context.l10n!.add.toUpperCase(),
                            ),
                            onPressed: () async {
                              if (id.isNotEmpty) {
                                ShowSnackBar().showSnackBar(
                                  context,
                                  await addUserPlaylist(id, context),
                                );
                              } else if (customPlaylistName.isNotEmpty) {
                                ShowSnackBar().showSnackBar(
                                  context,
                                  createCustomPlaylist(
                                    customPlaylistName,
                                    imageUrl,
                                    context,
                                  ),
                                );
                              } else {
                                ShowSnackBar().showSnackBar(
                                  context,
                                  '${context.l10n!.provideIdOrNameError}.',
                                );
                              }

                              Navigator.pop(context);

                            },
                          ),
                        ],
                      );
                    },
                  );
                },
              );
            },
          ),
        ],
      );
    },
  );
}
