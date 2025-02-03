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

import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:shrayesh_patro/API/shrayesh_patro.dart';
import 'package:shrayesh_patro/extensions/l10n.dart';
import 'package:shrayesh_patro/main.dart';
import 'package:shrayesh_patro/widgets/confirmation_dialog.dart';
import 'package:shrayesh_patro/widgets/playlist_cube.dart';
import 'package:shrayesh_patro/widgets/spinner.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';

import '../Backup/seek_bar.dart';
import '../Extra/test.dart';
import '../Update/page_route.dart';

class UserPlaylistsPage extends StatefulWidget {
  const UserPlaylistsPage({super.key});

  @override
  State<UserPlaylistsPage> createState() => _UserPlaylistsPageState();
}

class _UserPlaylistsPageState extends State<UserPlaylistsPage> {
  late Future<List> _playlistsFuture;

  @override
  void initState() {
    super.initState();
    _playlistsFuture = getUserPlaylists();
  }

  Future<void> _refreshPlaylists() async {
    setState(() {
      _playlistsFuture = getUserPlaylists();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
        centerTitle: true,
        title: Text(context.l10n!.userPlaylists),
      ),
      floatingActionButton: FloatingActionButton(
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
                          await _refreshPlaylists();
                        },
                      ),
                    ],
                  );
                },
              );
            },
          );
        },
        child: const Icon(FluentIcons.add_24_filled),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(top: 15),
        child: FutureBuilder(
          future: _playlistsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Spinner();
            } else if (snapshot.hasError) {
              logger.log(
                'Error on user playlists page',
                snapshot.error,
                snapshot.stackTrace,
              );
              return Center(
                child: Text(context.l10n!.error),
              );
            }

            final _playlists = snapshot.data as List;

            return GridView.builder(
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 200,
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
              ),
              shrinkWrap: true,
              physics: const ScrollPhysics(),
              itemCount: _playlists.length,
              padding: const EdgeInsets.all(16),
              itemBuilder: (BuildContext context, index) {
                final playlist = _playlists[index];
                final ytid = playlist['ytid'];

                return GestureDetector(
                  onTap: playlist['isCustom'] ?? false
                      ? () async {
                          final result = await  Navigator.push(
                            context,
                            AdaptivePageRoute.create(
                                  (context) =>
                                  TestPage(playlistData: playlist),
                            ),
                          );
                          if (result == false) {
                            setState(() {});
                          }
                        }
                      : null,
                  onLongPress: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return ConfirmationDialog(
                          confirmationMessage:
                              context.l10n!.removePlaylistQuestion,
                          submitMessage: context.l10n!.remove,
                          onCancel: () {
                            Navigator.of(context).pop();
                          },
                          onSubmit: () {
                            Navigator.of(context).pop();

                            if (ytid == null && playlist['isCustom']) {
                              removeUserCustomPlaylist(playlist);
                            } else {
                              removeUserPlaylist(ytid);
                            }

                            _refreshPlaylists();
                          },
                        );
                      },
                    );
                  },
                  child: PlaylistCube(
                    playlist,
                    playlistData:
                        playlist['isCustom'] ?? false ? playlist : null,
                    onClickOpen: playlist['isCustom'] == null,
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
