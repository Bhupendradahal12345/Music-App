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


import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hive/hive.dart';
import 'package:shrayesh_patro/extensions/l10n.dart';
import '../API/languagecodes.dart';
import '../API/shrayesh_patro.dart';
import '../Backup/backup_and_restore.dart';
import '../Backup/ext.dart';
import '../Backup/gradient_containers.dart';
import '../Backup/picker.dart';
import '../Backup/seek_bar.dart';
import '../Update/about_screen.dart';
import '../Update/page_route.dart';
import '../main.dart';
import '../screens/search_page.dart';

import '../services/data_manager.dart';
import '../services/settings_manager.dart';
import '../style/player_gradient.dart';
import '../style/theme.dart';
import '../utilities/flutter_bottom_sheet.dart';

import '../widgets/confirmation_dialog.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final Box settingsBox = Hive.box('settings');
  String downloadPath = Hive.box('settings')
      .get('downloadPath', defaultValue: '/storage/emulated/0/Music') as String;
  final ValueNotifier<bool> includeOrExclude = ValueNotifier<bool>(
    Hive.box('settings').get('includeOrExclude', defaultValue: false) as bool,
  );
  List includedExcludedPaths = Hive.box('settings')
      .get('includedExcludedPaths', defaultValue: []) as List;
  String lang =
  Hive.box('settings').get('lang', defaultValue: 'English') as String;
  bool useProxy =
  Hive.box('settings').get('useProxy', defaultValue: false) as bool;
  List miniButtonsOrder = Hive.box('settings').get(
    'miniButtonsOrder',
    defaultValue: ['Like', 'Previous', 'Play/Pause', 'Next', 'Download'],
  ) as List;
  List preferredMiniButtons = Hive.box('settings').get(
    'preferredMiniButtons',
    defaultValue: ['Like', 'Play/Pause', 'Next'],
  )?.toList() as List;
  List<int> preferredCompactNotificationButtons = Hive.box('settings').get(
    'preferredCompactNotificationButtons',
    defaultValue: [1, 2, 3],
  ) as List<int>;


  @override
  Widget build(BuildContext context) {
    return GradientContainer(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          centerTitle: true,
          title: Text(
            AppLocalizations.of(
              context,
            )!
                .settings,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Theme.of(context).iconTheme.color,
            ),
          ),
          iconTheme: IconThemeData(
            color: Theme.of(context).iconTheme.color,
          ),
        ),
        body: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(5.0),
          children: [
            ListTile(
              leading: const Icon(Icons.sunny),
              title: Text(
                AppLocalizations.of(
                  context,
                )!
                    .themeMode,

                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold
                ),
              ),
              subtitle: Text(
                AppLocalizations.of(
                  context,
                )!
                    .themeModeSub,
              ),
              dense: true,
              onTap: () {
                Navigator.push(
                  context,
                  AdaptivePageRoute.create(
                        (context) => const ThemePage(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.language),
              title: Text(
                AppLocalizations.of(
                  context,
                )!
                    .language,
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold
                ),
              ),
              subtitle: Text(
                AppLocalizations.of(
                  context,
                )!
                    .languageSub,
              ),
              onTap: () {},
              trailing: DropdownButton(
                value: lang,
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).textTheme.bodyLarge!.color,
                ),
                underline: const SizedBox(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(
                          () {
                        lang = newValue;
                        MyApp.of(context).setLocale(
                          Locale.fromSubtags(
                            languageCode:
                            LanguageCodes.languageCodes[newValue] ?? 'en',
                          ),
                        );
                        Hive.box('settings').put('lang', newValue);
                      },
                    );
                  }
                },
                items: LanguageCodes.languageCodes.keys
                    .map<DropdownMenuItem<String>>((language) {
                  return DropdownMenuItem<String>(
                    value: language,
                    child: Text(
                      language,
                    ),
                  );
                }).toList(),
              ),
              dense: true,
            ),
            ListTile(
              leading: const Icon(Icons.download),
              title: Text(
                AppLocalizations.of(
                  context,
                )!
                    .downLocation,
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold
                ),
              ),
              subtitle: Text(downloadPath),
              trailing: TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context).brightness ==
                      Brightness.dark
                      ? Colors.white
                      : Colors.grey[700],
                ),
                onPressed: () async {
                  downloadPath =
                      await Ext.getExtStorage(
                        dirName: 'Music',
                      ) ??
                          '/storage/emulated/0/Music';
                  Hive.box('settings')
                      .put('downloadPath', downloadPath);
                  setState(
                        () {},
                  );
                },
                child: Text(
                  AppLocalizations.of(
                    context,
                  )!
                      .reset,
                ),
              ),
              onTap: () async {
                final String temp = await Picker.selectFolder(
                  context: context,
                  message: AppLocalizations.of(
                    context,
                  )!
                      .selectDownLocation,
                );
                if (temp.trim() != '') {
                  downloadPath = temp;
                  Hive.box('settings').put('downloadPath', temp);
                  setState(
                        () {},
                  );
                } else {
                  ShowSnackBar().showSnackBar(
                    context,
                    AppLocalizations.of(
                      context,
                    )!
                        .noFolderSelected,
                  );
                }
              },
              dense: true,
            ),
            ListTile(
              leading: const Icon(Icons.design_services_rounded),
              title: Text(
                AppLocalizations.of(
                  context,
                )!
                    .playerScreenBackground,
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold
                ),
              ),

              subtitle: Text(
                AppLocalizations.of(
                  context,
                )!
                    .playerScreenBackgroundSub,
              ),
              dense: true,
              onTap: () {
                Navigator.push(
                  context,
                  AdaptivePageRoute.create(
                        (context) => const PlayerGradientSelection(),
                  ),
                );
              },
            ),

            ValueListenableBuilder<bool>(
              valueListenable: playNextSongAutomatically,
              builder: (_, value, __) {
                return ListTile(
                  leading: const Icon(Icons.music_note_rounded),
                  title: Text(
                    AppLocalizations.of(
                      context,
                    )!
                        .automaticSongPicker,
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold
                    ),
                  ),
                  subtitle: Text(
                    AppLocalizations.of(
                      context,
                    )!
                        .automaticSongPickerSub,
                  ),
                  trailing: Switch(
                    value: value,
                    onChanged: (value) {
                      audioHandler.changeAutoPlayNextStatus();
                      ShowSnackBar().showSnackBar(
                        context,
                        context.l10n!.settingChangedMsg,

                      );
                    },
                  ),
                );
              },
            ),

            ListTile(
              leading: const Icon(Icons.audio_file_rounded),
              title: Text(

                AppLocalizations.of(
                  context,
                )!
                    .audioQuality,
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold
                ),
              ),
              subtitle: Text(
                AppLocalizations.of(
                  context,
                )!
                    .audioQualitySub,
              ),
              onTap: () {
                final availableQualities = ['low', 'medium', 'high'];

                showCustomBottomSheet(
                  context,
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const BouncingScrollPhysics(),
                    itemCount: availableQualities.length,
                    itemBuilder: (context, index) {
                      final quality = availableQualities[index];
                      final isCurrentQuality =
                          audioQualitySetting.value == quality;

                      return Card(
                        color: isCurrentQuality
                            ? Theme.of(context).colorScheme.secondary
                            :  Colors.transparent,
                        margin: const EdgeInsets.all(10),
                        child: ListTile(
                          minTileHeight: 65,
                          title: Text(quality),
                          onTap: () {
                            addOrUpdateData(
                              'settings',
                              'audioQuality',
                              quality,
                            );
                            audioQualitySetting.value = quality;

                            ShowSnackBar().showSnackBar(
                              context,
                              context.l10n!.audioQualityMsg,
                            );
                            Navigator.pop(context);
                          },
                        ),
                      );
                    },
                  ),
                );
              },
            ),

            ListTile(
              leading: const Icon(Icons.cleaning_services),
              title: Text(
                AppLocalizations.of(
                  context,
                )!
                    .clearCache,
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold
                ),
              ),
              subtitle: Text(
                AppLocalizations.of(
                  context,
                )!
                    .clearCacheSub,
              ),
              onTap: () {
                clearCache();
                ShowSnackBar().showSnackBar(
                  context,
                  '${context.l10n!.cacheMsg}!',
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.play_circle),
              title: Text(
                AppLocalizations.of(
                  context,
                )!
                    .miniButtons,
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold
                ),
              ),
              subtitle: Text(
                AppLocalizations.of(
                  context,
                )!
                    .miniButtonsSub,
              ),
              dense: true,
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    final List checked = List.from(preferredMiniButtons);
                    final List<String> order = List.from(miniButtonsOrder);
                    return StatefulBuilder(
                      builder: (
                          BuildContext context,
                          StateSetter setStt,
                          ) {
                        return AlertDialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              15.0,
                            ),
                          ),
                          content: SizedBox(
                            width: 500,
                            child: ReorderableListView(
                              physics: const BouncingScrollPhysics(),
                              shrinkWrap: true,
                              padding: const EdgeInsets.fromLTRB(
                                0,
                                10,
                                0,
                                10,
                              ),
                              onReorder: (int oldIndex, int newIndex) {
                                if (oldIndex < newIndex) {
                                  newIndex--;
                                }
                                final temp = order.removeAt(
                                  oldIndex,
                                );
                                order.insert(newIndex, temp);
                                setStt(
                                      () {},
                                );
                              },
                              header: Center(
                                child: Text(
                                  AppLocalizations.of(
                                    context,
                                  )!
                                      .changeOrder,
                                ),
                              ),
                              children: order.map((e) {
                                return Row(
                                  key: Key(e),
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    ReorderableDragStartListener(
                                      index: order.indexOf(e),
                                      child: const Icon(
                                        Icons.drag_handle_rounded,
                                      ),
                                    ),
                                    Expanded(
                                      child: SizedBox(
                                        child: CheckboxListTile(
                                          dense: true,
                                          contentPadding: const EdgeInsets.only(
                                            left: 16.0,
                                          ),
                                          activeColor: Theme.of(context)
                                              .colorScheme
                                              .secondary,
                                          checkColor: Theme.of(
                                            context,
                                          ).colorScheme.secondary ==
                                              Colors.white
                                              ? Colors.black
                                              : null,
                                          value: checked.contains(e),
                                          title: Text(e),
                                          onChanged: (bool? value) {
                                            setStt(
                                                  () {
                                                value!
                                                    ? checked.add(e)
                                                    : checked.remove(e);
                                              },
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              }).toList(),
                            ),
                          ),
                          actions: [
                            TextButton(
                              style: TextButton.styleFrom(
                                foregroundColor: Theme.of(context).brightness ==
                                    Brightness.dark
                                    ? Colors.white
                                    : Colors.grey[700],
                              ),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Text(
                                AppLocalizations.of(
                                  context,
                                )!
                                    .cancel,
                              ),
                            ),
                            TextButton(
                              style: TextButton.styleFrom(
                                foregroundColor:
                                Theme.of(context).colorScheme.secondary ==
                                    Colors.white
                                    ? Colors.black
                                    : null,
                                backgroundColor:
                                Theme.of(context).colorScheme.secondary,
                              ),
                              onPressed: () {
                                setState(
                                      () {
                                    final List temp = [];
                                    for (int i = 0; i < order.length; i++) {
                                      if (checked.contains(order[i])) {
                                        temp.add(order[i]);
                                      }
                                    }
                                    preferredMiniButtons = temp;
                                    miniButtonsOrder = order;
                                    Navigator.pop(context);
                                    Hive.box('settings').put(
                                      'preferredMiniButtons',
                                      preferredMiniButtons,
                                    );
                                    Hive.box('settings').put(
                                      'miniButtonsOrder',
                                      order,
                                    );
                                  },
                                );
                              },
                              child: Text(
                                AppLocalizations.of(
                                  context,
                                )!
                                    .ok,
                              ),
                            ),
                            const SizedBox(
                              width: 5,
                            ),
                          ],
                        );
                      },
                    );
                  },
                );
              },
            ),

            ListTile(
              leading: const Icon(Icons.search_off),
              title: Text(
                AppLocalizations.of(
                  context,
                )!
                    .clearSearchHistory,
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold
                ),
              ),
              subtitle: Text(
                AppLocalizations.of(
                  context,
                )!
                    .clearSearchHistorySub,
              ),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return ConfirmationDialog(
                      submitMessage: context.l10n!.clear,
                      confirmationMessage:
                      context.l10n!.clearSearchHistoryQuestion,
                      onCancel: () => {Navigator.of(context).pop()},
                      onSubmit: () => {
                        Navigator.of(context).pop(),
                        searchHistory = [],
                        deleteData('user', 'searchHistory'),
                        ShowSnackBar().showSnackBar(
                          context,
                          '${context.l10n!.searchHistoryMsg}!',
                        ),
                      },
                    );
                  },
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.play_circle),
              title: Text(
                AppLocalizations.of(
                  context,
                )!
                    .clearRecentlyPlayed,
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold
                ),
              ),
              subtitle: Text(
                AppLocalizations.of(
                  context,
                )!
                    .clearRecentlyPlayedSub,
              ),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return ConfirmationDialog(
                      submitMessage: context.l10n!.clear,
                      confirmationMessage:
                      context.l10n!.clearRecentlyPlayedQuestion,
                      onCancel: () => {Navigator.of(context).pop()},
                      onSubmit: () => {
                        Navigator.of(context).pop(),
                        userRecentlyPlayed = [],
                        deleteData('user', 'recentlyPlayedSongs'),
                        ShowSnackBar().showSnackBar(
                          context,
                          '${context.l10n!.recentlyPlayedMsg}!',
                        ),
                      },
                    );
                  },
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings_backup_restore_rounded),
              title: Text(
                AppLocalizations.of(
                  context,
                )!
                    .backupUserData,
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold
                ),
              ),
              subtitle: Text(
                AppLocalizations.of(
                  context,
                )!
                    .backupUserDataSub,
              ),
              onTap: () {
                Navigator.push(
                  context,
                  CupertinoPageRoute(builder: (context) => const BackupAndRestorePage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.note_rounded),
              title: Text(
                AppLocalizations.of(
                  context,
                )!
                    .copyLogs,
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold
                ),
              ),
              subtitle: Text(
                AppLocalizations.of(
                  context,
                )!
                    .copyLogsSub,
              ),
              onTap: () async =>
                  ShowSnackBar().showSnackBar(context, await logger.copyLogs(context)),
            ),
            ListTile(
              leading: const Icon(Icons.info_rounded),
              title: Text(
                AppLocalizations.of(
                  context,
                )!
                    .about,
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold
                ),
              ),
              subtitle: Text(
                AppLocalizations.of(
                  context,
                )!
                    .aboutSub,
              ),
              onTap: () =>  Navigator.push(
                context,
                CupertinoPageRoute(builder: (context) => const AboutScreen()),
              ),
            )
          ],
        ),
      ),
    );
  }
}
