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


import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:on_audio_query/on_audio_query.dart';

import '../API/shrayesh_patro.dart';
import '../Downloads/download_button.dart';
import '../main.dart';
import 'audio_query.dart';
import 'image_card.dart';

class DataSearch extends SearchDelegate {
  final List<SongModel> data;
  final String tempPath;

  DataSearch({required this.data, required this.tempPath}) : super();

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      if (query.isEmpty)
        IconButton(
          icon: const Icon(CupertinoIcons.search),
          tooltip: AppLocalizations.of(context)!.search,
          onPressed: () {},
        )
      else
        IconButton(
          onPressed: () {
            query = '';
          },
          tooltip: AppLocalizations.of(context)!.clear,
          icon: const Icon(
            Icons.clear_rounded,
          ),
        ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back_rounded),
      tooltip: AppLocalizations.of(context)!.back,
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestionList = query.isEmpty
        ? data
        : [
      ...{
        ...data.where(
              (element) =>
              element.title.toLowerCase().contains(query.toLowerCase()),
        ),
        ...data.where(
              (element) =>
              element.artist!.toLowerCase().contains(query.toLowerCase()),
        ),
      },
    ];
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(top: 10, bottom: 10),
      shrinkWrap: true,
      itemExtent: 70.0,
      itemCount: suggestionList.length,
      itemBuilder: (context, index) {
        final playlist = {
          'list': suggestionList,
        };
        return ListTile(
          leading: OfflineAudioQuery.offlineArtworkWidget(
            id: suggestionList[index].id,
            type: ArtworkType.AUDIO,
            tempPath: tempPath,
            fileName: suggestionList[index].displayNameWOExt,
          ),
          onTap: () {
            audioHandler.playPlaylistSong(
              playlist: activePlaylist != playlist ? playlist : null,
              songIndex: index,

            );
          },
          title: Text(
            suggestionList[index].title.trim() != ''
                ? suggestionList[index].title
                : suggestionList[index].displayNameWOExt,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(
            suggestionList[index].artist! == '<unknown>'
                ? AppLocalizations.of(context)!.unknown
                : suggestionList[index].artist!,
            overflow: TextOverflow.ellipsis,
          ),

        );
      },
    );

  }

  @override
  Widget buildResults(BuildContext context) {
    final suggestionList = query.isEmpty
        ? data
        : [
      ...{
        ...data.where(
              (element) =>
              element.title.toLowerCase().contains(query.toLowerCase()),
        ),
        ...data.where(
              (element) =>
              element.artist!.toLowerCase().contains(query.toLowerCase()),
        ),
      },
    ];
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(top: 10, bottom: 10),
      shrinkWrap: true,
      itemExtent: 70.0,
      itemCount: suggestionList.length,
      itemBuilder: (context, index) {
        final playlist = {
          'list': suggestionList,
        };
        return ListTile(
          leading: OfflineAudioQuery.offlineArtworkWidget(
            id: suggestionList[index].id,
            type: ArtworkType.AUDIO,
            tempPath: tempPath,
            fileName: suggestionList[index].displayNameWOExt,
          ),
          onTap: () {
            audioHandler.playPlaylistSong(
              playlist: activePlaylist != playlist ? playlist : null,
              songIndex: index,

            );
          },
          title: Text(
            suggestionList[index].title.trim() != ''
                ? suggestionList[index].title
                : suggestionList[index].displayNameWOExt,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(
            suggestionList[index].artist! == '<unknown>'
                ? AppLocalizations.of(context)!.unknown
                : suggestionList[index].artist!,
            overflow: TextOverflow.ellipsis,
          ),

        );
      },
    );

  }

  @override
  ThemeData appBarTheme(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return theme.copyWith(
      primaryColor: Theme.of(context).colorScheme.secondary,
      textSelectionTheme:
      const TextSelectionThemeData(cursorColor: Colors.white),
      hintColor: Colors.deepOrangeAccent,
      primaryIconTheme: theme.primaryIconTheme.copyWith(color: Colors.white),
      textTheme: theme.textTheme.copyWith(
        titleLarge:
        const TextStyle(fontWeight: FontWeight.normal, color: Colors.green),
      ),
      inputDecorationTheme:
      const InputDecorationTheme(focusedBorder: InputBorder.none),
    );
  }
}

class DownloadsSearch extends SearchDelegate {
  final bool isDowns;
  final List data;
  final Function(Map)? onDelete;

  DownloadsSearch({
    required this.data,
    this.isDowns = false,
    this.onDelete,
  });

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      if (query.isEmpty)
        IconButton(
          icon: const Icon(CupertinoIcons.search),
          tooltip: AppLocalizations.of(context)!.search,
          onPressed: () {},
        )
      else
        IconButton(
          onPressed: () {
            query = '';
          },
          tooltip: AppLocalizations.of(context)!.clear,
          icon: const Icon(
            Icons.clear_rounded,
          ),
        ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back_rounded),
      tooltip: AppLocalizations.of(context)!.back,
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestionList = query.isEmpty
        ? data
        : [
      ...{
        ...data.where(
              (element) => element['title']
              .toString()
              .toLowerCase()
              .contains(query.toLowerCase()),
        ),
        ...data.where(
              (element) => element['artist']
              .toString()
              .toLowerCase()
              .contains(query.toLowerCase()),
        ),
      },
    ];
    return ListView.builder(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.only(top: 10, bottom: 10),
        shrinkWrap: true,
        itemExtent: 70.0,
        itemCount: suggestionList.length,
        itemBuilder: (context, index) {
          final playlist = {
            'list': suggestionList,
          };
          return ListTile(
            leading: imageCard(
              imageUrl: isDowns
                  ? suggestionList[index]['image'].toString()
                  : suggestionList[index]['image'].toString(),
              localImage: isDowns,
            ),
            onTap: () {
              audioHandler.playPlaylistSong(
                playlist: activePlaylist != playlist ? playlist : null,
                songIndex: index,

              );
            },
            title: Text(
              suggestionList[index]['title'].toString(),
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              suggestionList[index]['artist'].toString(),
              overflow: TextOverflow.ellipsis,
            ),

          );
        }
    );

  }



  @override
  Widget buildResults(BuildContext context) {
    final suggestionList = query.isEmpty
        ? data
        : [
      ...{
        ...data.where(
              (element) => element['title']
              .toString()
              .toLowerCase()
              .contains(query.toLowerCase()),
        ),
        ...data.where(
              (element) => element['artist']
              .toString()
              .toLowerCase()
              .contains(query.toLowerCase()),
        ),
      },
    ];
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(top: 10, bottom: 10),
      shrinkWrap: true,
      itemExtent: 70.0,
      itemCount: suggestionList.length,
      itemBuilder: (context, index) {
        final playlist = {
          'list': suggestionList,
        };
        return ListTile(
          leading: imageCard(
            imageUrl: isDowns
                ? suggestionList[index]['image'].toString()
                : suggestionList[index]['image'].toString(),
            localImage: isDowns,
          ),
          onTap: () {
            audioHandler.playPlaylistSong(
              playlist: activePlaylist != playlist ? playlist : null,
              songIndex: index,

            );
          },
          title: Text(
            suggestionList[index]['title'].toString(),
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(
            suggestionList[index]['artist'].toString(),
            overflow: TextOverflow.ellipsis,
          ),

        );
      },
    );

  }

  @override
  ThemeData appBarTheme(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return theme.copyWith(
      primaryColor: Theme.of(context).colorScheme.secondary,
      textSelectionTheme:
      const TextSelectionThemeData(cursorColor: Colors.white),
      hintColor: Colors.deepOrangeAccent,
      primaryIconTheme: theme.primaryIconTheme.copyWith(color: Colors.white),
      textTheme: theme.textTheme.copyWith(
        titleLarge:
        const TextStyle(fontWeight: FontWeight.normal, color: Colors.green),
      ),
      inputDecorationTheme:
      const InputDecorationTheme(focusedBorder: InputBorder.none),
      scaffoldBackgroundColor: Colors.transparent,
    );
  }
}
