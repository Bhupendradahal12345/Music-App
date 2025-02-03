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

import 'package:shrayesh_patro/extensions/l10n.dart';
import 'package:shrayesh_patro/main.dart';
import 'package:shrayesh_patro/services/settings_manager.dart';
import 'package:shrayesh_patro/widgets/mini_player.dart';
import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../API/languagecodes.dart';


class BottomNavigationPage extends StatefulWidget {
  const BottomNavigationPage({
    super.key,
    required this.child,
  });

  final StatefulNavigationShell child;

  @override
  State<BottomNavigationPage> createState() => _BottomNavigationPageState();
}

class _BottomNavigationPageState extends State<BottomNavigationPage> {
  final _selectedIndex = ValueNotifier<int>(0);

  @override
  Widget build(BuildContext context) {
    // can be wrapped in the SafeArea:
    // body: SafeArea(
    //   child: widget.child,
    // ),

    return Scaffold(
      body: widget.child,
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          StreamBuilder<MediaItem?>(
            stream: audioHandler.mediaItem,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                logger.log(
                  'Error in mini player bar',
                  snapshot.error,
                  snapshot.stackTrace,
                );
              }
              final metadata = snapshot.data;
              if (metadata == null) {
                return const SizedBox.shrink();
              } else {
                return MiniPlayer(metadata: metadata);
              }
            },
          ),
          NavigationBar(
            backgroundColor: Colors.transparent,
            selectedIndex: _selectedIndex.value,
            labelBehavior: LanguageCodes == const Locale('en', '')
                ? NavigationDestinationLabelBehavior.onlyShowSelected
                : NavigationDestinationLabelBehavior.alwaysHide,
            onDestinationSelected: (index) {
              widget.child.goBranch(
                index,
                initialLocation: index == widget.child.currentIndex,
              );
              setState(() {
                _selectedIndex.value = index;
              });
            },
            destinations: !offlineMode.value
                ? [
              NavigationDestination(
                icon: Icon(Icons.home, color: Theme.of(context).colorScheme.primary),
                selectedIcon: Icon(Icons.home, color: Theme.of(context).colorScheme.secondary),
                label: context.l10n?.home ?? 'Home',
              ),
              NavigationDestination(
                icon: Icon(Icons.newspaper_outlined, color: Theme.of(context).colorScheme.primary),
                selectedIcon: Icon(Icons.newspaper_outlined, color: Theme.of(context).colorScheme.secondary),
                label: context.l10n?.news ?? 'News',
              ),
              NavigationDestination(
                icon: Icon(Icons.music_note, color: Theme.of(context).colorScheme.primary),
                selectedIcon: Icon(Icons.music_note, color: Theme.of(context).colorScheme.secondary),
                label: context.l10n?.songs ?? 'Songs',
              ),
              NavigationDestination(
                icon: Icon(Icons.library_music, color: Theme.of(context).colorScheme.primary),
                selectedIcon: Icon(Icons.library_music, color: Theme.of(context).colorScheme.secondary),
                label: context.l10n?.library ?? 'Library',
              ),
              NavigationDestination(
                icon: Icon(Icons.settings, color: Theme.of(context).colorScheme.primary),
                selectedIcon: Icon(Icons.settings, color: Theme.of(context).colorScheme.secondary),
                label: context.l10n?.settings ?? 'Settings',
              ),
            ]
                : [
              NavigationDestination(
                icon: Icon(Icons.home, color: Theme.of(context).colorScheme.primary),
                selectedIcon: Icon(Icons.home, color: Theme.of(context).colorScheme.secondary),
                label: context.l10n?.home ?? 'Home',
              ),
              NavigationDestination(
                icon: Icon(Icons.settings, color: Theme.of(context).colorScheme.primary),
                selectedIcon: Icon(Icons.settings, color: Theme.of(context).colorScheme.secondary),
                label: context.l10n?.settings ?? 'Settings',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
