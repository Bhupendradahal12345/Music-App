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
import 'dart:io';
import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/cupertino.dart';
import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';
import 'package:shrayesh_patro/API/shrayesh_patro.dart';
import 'package:shrayesh_patro/extensions/l10n.dart';
import 'package:shrayesh_patro/screens/search_page.dart';
import 'package:shrayesh_patro/screens/sideup-view.dart';
import 'package:shrayesh_patro/services/settings_manager.dart';
import 'package:shrayesh_patro/utilities/formatter.dart';
import 'package:shrayesh_patro/utilities/mediaitem.dart';
import 'package:shrayesh_patro/widgets/marque.dart';
import 'package:shrayesh_patro/widgets/playback_icon_button.dart';
import 'package:shrayesh_patro/widgets/song_artwork.dart';
import 'package:shrayesh_patro/widgets/spinner.dart';
import 'package:shrayesh_patro/widgets/squiggly_slider.dart';
import 'package:audio_service/audio_service.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_flip_card/flutter_flip_card.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:url_launcher/url_launcher.dart';
import '../Backup/config.dart';
import '../Backup/dominant_color.dart';
import '../Backup/seek_bar.dart';
import '../Backup/textinput_dialog.dart';
import '../Downloads/download_button.dart';

import '../main.dart';
import '../models/position_data.dart';


final _lyricsController = FlipCardController();

class NowPlayingPage extends StatefulWidget {
  const NowPlayingPage({super.key});
  @override
  _NowPlayingPageState createState() => _NowPlayingPageState();
}

class _NowPlayingPageState extends State<NowPlayingPage> {
  final String gradientType = Hive.box('settings')
      .get('gradientType', defaultValue: 'fullMixDarker')
      .toString();
  final bool getLyricsOnline =
  Hive.box('settings').get('getLyricsOnline', defaultValue: true) as bool;
  final MyTheme currentTheme = GetIt.I<MyTheme>();
  final ValueNotifier<List<Color?>?> gradientColor =
  ValueNotifier<List<Color?>?>(GetIt.I<MyTheme>().playGradientColor);
  late Duration _time;

  bool isSharePopupShown = false;

  BuildContext? get scaffoldContext => context;

  void sleepTimer(int time) {
    audioHandler.customAction('sleepTimer', {'time': time});
  }

  void sleepCounter(int count) {
    audioHandler.customAction('sleepCounter', {'count': count});
  }

  Future<dynamic> setTimer(
      BuildContext context,
      BuildContext? scaffoldContext,
      ) {
    return showDialog(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: Center(
            child: Text(
              context.l10n!.selectDur,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
          ),
          children: [
            Center(
              child: SizedBox(
                height: 200,
                width: 200,
                child: CupertinoTheme(
                  data: CupertinoThemeData(
                    brightness: CupertinoTheme.of(context).brightness,
                    textTheme: CupertinoTextThemeData(
                      dateTimePickerTextStyle: TextStyle(
                        fontSize: 16,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                  ),
                  child: CupertinoTimerPicker(
                    mode: CupertinoTimerPickerMode.hm,
                    onTimerDurationChanged: (value) {
                      _time = value;
                    },
                  ),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.secondary,
                  ),
                  onPressed: () {
                    sleepTimer(0);
                    Navigator.pop(context);
                  },
                  child: Text(context.l10n!.cancel),
                ),
                const SizedBox(
                  width: 10,
                ),
                TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    foregroundColor:
                    Theme.of(context).colorScheme.secondary == Colors.white
                        ? Colors.black
                        : Colors.white,
                  ),
                  onPressed: () {
                    sleepTimer(_time.inMinutes);
                    Navigator.pop(context);
                    ShowSnackBar().showSnackBar(
                      context,
                      '${context.l10n!.sleepTimerSetFor} ${_time.inMinutes} ${context.l10n!.minutes}',
                    );
                  },
                  child: Text(context.l10n!.ok),


                ),
                const SizedBox(
                  width: 20,
                ),
              ],
            ),
          ],
        );
      },
    );
  }
  Future<dynamic> setCounter() async {
    showTextInputDialog(
      context: context,
      title: context.l10n!.enterSongsCount,
      initialText: '',
      keyboardType: TextInputType.number,
      onSubmitted: (String value, BuildContext context) {
        sleepCounter(
          int.parse(value),
        );
        Navigator.pop(context);
        ShowSnackBar().showSnackBar(
          context,
          '${context.l10n!.sleepTimerSetFor} $value ${context.l10n!.songs}',
        );
      },
    );
  }

  void updateBackgroundColors(List<Color?> value) {
    gradientColor.value = value;
    return;
  }

  @override
  Widget build(BuildContext context) {
    BuildContext? scaffoldContext;
    final size = MediaQuery
        .of(context)
        .size;
    return Dismissible(
        direction: DismissDirection.down,
        background: const ColoredBox(color: Colors.transparent),
        key: const Key('playScreen'),
        onDismissed: (direction) {
          Navigator.pop(context);
        },
        child: StreamBuilder<MediaItem?>(
            stream: audioHandler.mediaItem,
            builder: (context, snapshot) {
              final MediaItem? mediaItem = snapshot.data;
              if (mediaItem == null) return const SizedBox();
              if (mediaItem.artUri != null && mediaItem.artUri.toString() != '') {
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
                  child: Scaffold(
                      resizeToAvoidBottomInset: false,
                      backgroundColor: Colors.transparent,
                      appBar: AppBar(
                          elevation: 0,
                          backgroundColor: Colors.transparent,
                          centerTitle: true,
                          leading: IconButton(
                            icon: const Icon(Icons.expand_more_rounded),
                            tooltip: AppLocalizations.of(context)!.back,
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          ),
                          actions: [
                            IconButton(
                              icon: const Icon(Icons.lyrics_rounded),
                              tooltip: 'Lyrice',
                              onPressed: _lyricsController.flipcard,
                            ), //IconButton

                            PopupMenuButton<int>(
                                itemBuilder: (context) => [
                                  // PopupMenuItem 1
                                  PopupMenuItem(
                                    value: 1,
                                    child: Row(
                                      children: [
                                        Icon(
                                          CupertinoIcons.search,
                                          color: Theme.of(context).iconTheme.color,
                                        ),
                                        const SizedBox(width: 10.0),
                                        Text(
                                          context.l10n!.searchVideo,
                                        ),
                                      ],
                                    ),
                                  ),

                                  // PopupMenuItem 2
                                  PopupMenuItem(
                                    value: 2,
                                    child: Row(
                                      children: [
                                        Icon(
                                          CupertinoIcons.timer,
                                          color: Theme.of(context).iconTheme.color,
                                        ),
                                        const SizedBox(width: 10.0),
                                        Text(
                                          context.l10n!.sleepTimer,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                                offset: const Offset(0, 40),
                                elevation: 0,
                                // on selected we show the dialog box
                                onSelected: (value) {
                                  // if value 1 show dialog
                                  if (value == 1) {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                            const SearchPage(
                                            )
                                        )
                                    );
                                  } else if (value == 2) {
                                    showDialog(
                                      context: context,
                                      builder: (context) {
                                        return SimpleDialog(
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(15.0),
                                          ),
                                          title: Text(
                                            context.l10n!.sleepTimer,
                                            style: TextStyle(
                                              color:
                                              Theme
                                                  .of(context)
                                                  .colorScheme
                                                  .secondary,
                                            ),
                                          ),
                                          contentPadding: const EdgeInsets.all(10.0),
                                          children: [
                                            ListTile(
                                              title: Text(
                                                context.l10n!.sleepDur,
                                              ),
                                              subtitle: Text(
                                                context.l10n!.sleepDurSub,
                                              ),
                                              dense: true,
                                              onTap: () {
                                                Navigator.pop(context);
                                                setTimer(
                                                  context,
                                                  scaffoldContext,
                                                );
                                              },
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  }
                                }
                            )
                          ]
                      ),
                      body: SlidingUpPanel(
                        color: Colors.transparent,
                        padding: EdgeInsets.zero,
                        margin: EdgeInsets.zero,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                        boxShadow: const [],
                        minHeight: 50 +
                            MediaQuery
                                .of(context)
                                .padding
                                .bottom,
                        panel: ClipRRect(
                          borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(20),
                              topRight: Radius.circular(20)),
                          child: Container(
                            width: 20, //////// ..test test   ////////////////////////
                            alignment: Alignment.center,
                            decoration: const BoxDecoration(
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(20),
                                  topRight:
                                  Radius.circular(20)),
                            ),
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.center,
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                ClipRRect(
                                  child: BackdropFilter(
                                    filter: ImageFilter.blur(
                                        sigmaX: 3, sigmaY: 3),
                                    child: Container(
                                      height: 50 +
                                          MediaQuery
                                              .of(context)
                                              .padding
                                              .bottom,
                                      width: double.maxFinite,
                                      decoration: BoxDecoration(
                                        color: Theme
                                            .of(context)
                                            .scaffoldBackgroundColor
                                            .withAlpha(70),
                                        borderRadius:
                                        const BorderRadius
                                            .only(
                                            topLeft: Radius
                                                .circular(
                                                20),
                                            topRight: Radius
                                                .circular(
                                                20)),
                                      ),
                                      child: Column(
                                        mainAxisSize:
                                        MainAxisSize.max,
                                        mainAxisAlignment:
                                        MainAxisAlignment
                                            .center,
                                        children: [
                                          Container(
                                            height: 5,
                                            width: 50,
                                            decoration:
                                            BoxDecoration(
                                              color: Theme.of(context).colorScheme.secondary,
                                              borderRadius:
                                              BorderRadius
                                                  .circular(
                                                  20),
                                            ),
                                          ),
                                          const SizedBox(
                                              height: 8),
                                          Text(
                                              AppLocalizations.of(context)!
                                                  .upNext

                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                const Expanded(
                                    child: Sideup_View(page: 'recents',)
                                )
                              ],
                            ),
                          ),
                        ),
                        body: StreamBuilder<MediaItem?>(
                          stream: audioHandler.mediaItem,
                          builder: (context, snapshot) {
                            if (snapshot.data == null || !snapshot.hasData) {
                              return const SizedBox.shrink();
                            } else {
                              final metadata = snapshot.data!;
                              final screenHeight = size.height;

                              return Column(
                                children: [
                                  SizedBox(height: screenHeight * 0.02),
                                  buildArtwork(context, size, metadata),
                                  SizedBox(height: screenHeight * 0.01),
                                  if (!(metadata.extras?['isLive'] ?? false))
                                    _buildPlayer(
                                      context,
                                      size,
                                      metadata.extras?['ytid'],
                                      metadata,
                                    ),
                                ],
                              );
                            }
                          },
                        ),
                      )
                  ),
                ),
                builder: (BuildContext context, List<Color?>? value, Widget? child) {
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
                            ? Theme.of(context).brightness == Brightness.dark
                            ? currentTheme.getBackGradient()
                            : [
                          const Color(0xfff5f9ff),
                          Colors.white,
                        ]
                            : Theme.of(context).brightness == Brightness.dark
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
    );
  }

  Widget buildArtwork(BuildContext context, Size size, MediaItem metadata) {
    const padding = 70;
    const radius = 17.0;
    final screen = (size.width + size.height) / 3.05;
    final imageSize = screen - padding;

    return FlipCard(
      rotateSide: RotateSide.right,
      onTapFlipping: !offlineMode.value,
      controller: _lyricsController,
      frontWidget: SongArtworkWidget(
        metadata: metadata,
        size: imageSize,
        errorWidgetIconSize: size.width / 8,
        borderRadius: radius,
      ),
      backWidget: Container(
        width: imageSize,
        height: imageSize,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondary,
          borderRadius: BorderRadius.circular(radius),
        ),
        child: ValueListenableBuilder<String?>(
          valueListenable: lyrics,
          builder: (_, value, __) {
            if (lastFetchedLyrics != '${metadata.artist} - ${metadata.title}') {
              getSongLyrics(
                metadata.artist ?? '',
                metadata.title,
              );
            }
            if (value != null && value != 'not found') {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(12),
                child: Center(
                  child: Text(
                    value,
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            } else if (value == null) {
              return const Spinner();
            } else {
              return Center(
                child: Text(
                  context.l10n!.lyricsNotAvailable,
                  style: const TextStyle(
                    fontSize: 25,
                  ),
                  textAlign: TextAlign.center,
                ),
              );
            }
          },
        ),
      ),
    );
  }

  Widget buildMarqueeText(
      String text,
      Color fontColor,
      double fontSize,
      FontWeight fontWeight,
      ) {
    return MarqueeWidget(
      backDuration: const Duration(seconds: 1),
      child: Text(
        text,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: fontColor,
        ),
      ),
    );
  }

  Widget _buildPlayer(
      BuildContext context,
      Size size,
      dynamic audioId,
      MediaItem mediaItem,
      ) {
    const iconSize = 20.0;
    final screenWidth = size.width;
    final screenHeight = size.height;

    return Expanded(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                  child: GestureDetector(
                    onTap: (){
                      launchUrl(
                        Uri.parse('https://youtube.com/watch?v=${mediaItemToMap(mediaItem)["ytid"]}'),
                        mode: LaunchMode.externalApplication,
                      );
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: screenWidth * 0.85,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              buildMarqueeText(
                                mediaItem.title,
                                Theme.of(context).colorScheme.primary,
                                screenHeight * 0.028,
                                FontWeight.w600,
                              ),
                              SizedBox(height: screenHeight * 0.005),
                              if (mediaItem.artist != null)
                                buildMarqueeText(
                                  mediaItem.artist!,
                                  Theme.of(context).colorScheme.secondary,
                                  screenHeight * 0.025,
                                  FontWeight.w500,
                                ),
                            ],
                          ),
                        ),
                        SizedBox(height: size.height * 0.01),
                        buildPositionSlider(),
                        buildPlayerControls(context, size, mediaItem, iconSize),
                        SizedBox(height: size.height * 0.055),
                        buildBottomActions(context, audioId, mediaItem, iconSize),
                      ],
                    ),
                  )
              )
            ]
        )
    );
  }

  Widget buildPositionSlider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: StreamBuilder<PositionData>(
        stream: audioHandler.positionDataStream,
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data == null) {
            return const SizedBox.shrink();
          }
          final positionData = snapshot.data!;
          final primaryColor = Theme.of(context).colorScheme.primary;
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              buildSlider(
                positionData,
              ),
              buildPositionRow(
                primaryColor,
                positionData,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget buildSlider(
      positionData,
      ) {
    return SquigglySlider(
      value: positionData.position.inSeconds.toDouble(),
      onChanged: (value) {
        audioHandler.seek(Duration(seconds: value.toInt()));
      },
      max: positionData.duration.inSeconds.toDouble(),
      squiggleSpeed: 0,
    );
  }

  Widget buildPositionRow(Color fontColor, positionData) {
    final positionText = formatDuration(positionData.position.inSeconds);
    final durationText = formatDuration(positionData.duration.inSeconds);
    final textStyle = TextStyle(fontSize: 15, color: fontColor);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(positionText, style: textStyle),
          Text(durationText, style: textStyle),
        ],
      ),
    );
  }

  Widget buildPlayerControls(
      BuildContext context,
      Size size,
      MediaItem mediaItem,
      double iconSize,
      ) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final secondaryColor = Theme.of(context).colorScheme.secondaryContainer;

    final screen = ((size.width + size.height) / 4) - 10;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          ValueListenableBuilder<bool>(
            valueListenable: shuffleNotifier,
            builder: (_, value, __) {
              return value
                  ? IconButton.filled(
                icon:  Icon(
                    Icons.shuffle_rounded,
                    color: Theme.of(context).colorScheme.secondary
                ),
                iconSize: 30,
                onPressed: () {
                  audioHandler.setShuffleMode(
                    AudioServiceShuffleMode.none,
                  );
                },
              )
                  : IconButton(
                icon: Icon(
                  Icons.shuffle_rounded,
                  color: primaryColor,
                ),
                iconSize: 30,
                onPressed: () {
                  audioHandler.setShuffleMode(
                    AudioServiceShuffleMode.all,
                  );
                },
              );
            },
          ),
          Row(
            children: [
              IconButton(
                icon: Icon(
                  FluentIcons.previous_24_filled,
                  color: audioHandler.hasPrevious
                      ? primaryColor
                      : secondaryColor,
                ),
                iconSize: 30,
                onPressed: () => audioHandler.skipToPrevious(),
                splashColor: Colors.transparent,
              ),
              const SizedBox(width: 5),
              StreamBuilder<PlaybackState>(
                stream: audioHandler.playbackState,
                builder: (context, snapshot) {
                  return buildPlaybackIconButton(
                    snapshot.data,
                    screen * 0.15,
                    primaryColor,
                    secondaryColor,
                    elevation: 0,
                    padding: EdgeInsets.all(screen * 0.08),
                  );
                },
              ),
              const SizedBox(width: 5),
              IconButton(
                icon: Icon(
                  FluentIcons.next_24_filled,
                  color: audioHandler.hasNext ? primaryColor : secondaryColor,
                ),
                iconSize: 30,
                onPressed: () => audioHandler.skipToNext(),
                splashColor: Colors.transparent,
              ),
            ],
          ),
          ValueListenableBuilder<bool>(
            valueListenable: repeatNotifier,
            builder: (_, value, __) {
              return value
                  ? IconButton(
                icon: Icon(
                    Icons.repeat_one_rounded,
                    color: Theme.of(context).colorScheme.secondary
                ),
                iconSize: 30,
                onPressed: () {
                  audioHandler.setRepeatMode(
                    AudioServiceRepeatMode.none,
                  );
                },
              )
                  : IconButton(
                icon: Icon(
                  Icons.repeat_rounded,
                  color: primaryColor,
                ),
                iconSize: 30,
                onPressed: () {
                  audioHandler.setRepeatMode(
                    AudioServiceRepeatMode.all,
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget buildBottomActions(
      BuildContext context,
      dynamic audioId,
      MediaItem mediaItem,
      double iconSize,
      ) {
    final MediaItem mediaItem = audioHandler.mediaItem.value!;
    final bool online = mediaItem.extras!['url'].toString().startsWith('http');
    final songLikeStatus = ValueNotifier<bool>(isSongAlreadyLiked(audioId));
    late final songOfflineStatus =
    ValueNotifier<bool>(isSongAlreadyOffline(audioId));
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 78,
      children: [
        if (!offlineMode.value)
          ValueListenableBuilder<bool>(
            valueListenable: songOfflineStatus,
            builder: (_, value, __) {
              return !online
                  ? const SizedBox()
                  :DownloadButton(
                  size: 30.0,
                  icon: 'download',
                  data: mediaItemToMap(mediaItem)
              );
            },
          ),
        if (!offlineMode.value)
          ValueListenableBuilder<bool>(
            valueListenable: songOfflineStatus,
            builder: (_, value, __) {
              return !online
                  ? const SizedBox()
              :IconButton(
                icon: Icon(
                  size: 30,
                  value ? CupertinoIcons.checkmark_rectangle_fill : CupertinoIcons.cloud_download,
                  color: value ? Theme.of(context).colorScheme.secondary : Theme.of(context).iconTheme.color,
                ),
                iconSize: 30,
                onPressed: () {
                  if (value) {
                    removeSongFromOffline(audioId);
                  } else {
                    makeSongOffline(mediaItemToMap(mediaItem));
                  }

                  songOfflineStatus.value = !songOfflineStatus.value;
                },
              );
            },
          ),
        if (!offlineMode.value)
          ValueListenableBuilder<bool>(
            valueListenable: songLikeStatus,
            builder: (_, value, __) {
              return !online
                  ? const SizedBox()
                  :IconButton(
                icon: Icon(
                  size: 30,
                  value ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                  color: value ? Theme.of(context).colorScheme.secondary : Theme.of(context).iconTheme.color,
                ),
                iconSize: 30,
                onPressed: () {
                  updateSongLikeStatus(audioId, !songLikeStatus.value);
                  songLikeStatus.value = !songLikeStatus.value;
                },
              );
            },
          ),
        //     AdaptiveIconButton(
        //       onPressed: () {
        // Update.showPlayerOptionsModal(  //
        //      context, //
        //   //  );
        //      },
        //       icon: Icon(
        //        AdaptiveIcons.more_vertical,
        //        size: 30,
        //  )

        // ),

      ],
    );

  }
}




