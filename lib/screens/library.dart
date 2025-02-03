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




import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:shrayesh_patro/screens/recent.dart';
import 'package:shrayesh_patro/screens/user_added_playlists_page.dart';
import 'package:shrayesh_patro/screens/user_liked_playlists_page.dart';



import '../Download_Music/downloads.dart';

import '../Extra/favorite_page.dart';
import '../Extra/offlinepage.dart';
import '../Update/page_route.dart';

class LibraryPage extends StatefulWidget {
  const LibraryPage({super.key});

  @override
  _LibraryPageState createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> {
  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const BouncingScrollPhysics(),
      children: [
        AppBar(
          title: Text(
            AppLocalizations.of(context)!.library,
            style: TextStyle(
              color: Theme.of(context).iconTheme.color,
            ),
          ),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
          automaticallyImplyLeading: false,

        ),
        LibraryTile(
          title: AppLocalizations.of(context)!.downloads,
          icon: Icons.download,
          onTap: () {
            Navigator.push(
              context,
              AdaptivePageRoute.create(
                      (context) => const Downloads()
              ),

            );
          },
        ),
        LibraryTile(
          title: AppLocalizations.of(context)!.nowPlaying,
          icon: Icons.queue_music_rounded,
          onTap: () {
            Navigator.push(
              context,
              AdaptivePageRoute.create(
                    (context) => const Recent(page: 'recents'),
              ),
            );
          },
        ),
        LibraryTile(
          title: AppLocalizations.of(context)!.offline,
          icon: FluentIcons.cellular_off_24_regular,
          onTap: () {
            Navigator.push(
              context,
              AdaptivePageRoute.create(
                    (context) => const OfflinePage(page: 'offline'),
              ),
            );
          },
        ),
        LibraryTile(
          title: AppLocalizations.of(context)!.favorites,
          icon: Icons.favorite_rounded,
          onTap: () {
            Navigator.push(
              context,
              AdaptivePageRoute.create(
                    (context) => const FavoritePage(page: 'liked'),
              ),
            );
          },
        ),
        LibraryTile(
          title: AppLocalizations.of(context)!.playlists,
          icon: Icons.playlist_play_rounded,
          onTap: () {
            Navigator.push(
              context,
              AdaptivePageRoute.create(
                    (context) => const UserPlaylistsPage(),
              ),
            );
          },
        ),
        LibraryTile(
          title: AppLocalizations.of(context)!.album,
          icon: Icons.album,
          onTap: () {
            Navigator.push(
              context,
              AdaptivePageRoute.create(
                    (context) => const UserLikedPlaylistsPage(),

              ),

            );
          },
        ),
      ],
    );
  }
}

class LibraryTile extends StatelessWidget {
  const LibraryTile({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
    this.subtitle,
  });

  final String title;
  final String? subtitle;
  final IconData icon;
  final Function() onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        title,
        style: TextStyle(
          color: Theme.of(context).iconTheme.color,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
        subtitle!,
        style: TextStyle(
          color: Theme.of(context).iconTheme.color,
        ),
      )
          : null,
      leading: Icon(
        icon,
        color: Theme.of(context).iconTheme.color,
      ),
      onTap: onTap,
    );
  }
}
