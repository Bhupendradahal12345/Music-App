

import 'package:hive/hive.dart';
import 'package:shrayesh_patro/Backup/gradient_containers.dart';
import 'package:shrayesh_patro/Download_Music/image_card.dart';
import 'package:shrayesh_patro/main.dart';
import 'package:shrayesh_patro/screens/now_playing_page.dart';
import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';



import '../services/mini-player_support.dart';




class MiniPlayer extends StatelessWidget {
  const MiniPlayer({super.key, required this.metadata});
  final MediaItem metadata;

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.sizeOf(context).width;
    final double screenHeight = MediaQuery.sizeOf(context).height;
    final bool rotated = screenHeight < screenWidth;
    return SafeArea(
      top: false,
      child: StreamBuilder<MediaItem?>(
        stream: audioHandler.mediaItem,
        builder: (context, snapshot) {
          final MediaItem? mediaItem = snapshot.data;


          final List preferredMiniButtons = Hive.box('settings').get(
            'preferredMiniButtons',
            defaultValue: ['Like', 'Play/Pause', 'Next'],
          )?.toList() as List;

          final bool isLocal =
              mediaItem?.artUri?.toString().startsWith('file:') ?? false;

          final bool useDense = Hive.box('settings').get(
            'useDenseMini',
            defaultValue: false,
          ) as bool ||
              rotated;

          return Dismissible(
            key: const Key('miniplayer'),
            direction: DismissDirection.vertical,
            confirmDismiss: (DismissDirection direction) {
              if (mediaItem != null) {
                if (direction == DismissDirection.down) {
                  audioHandler.stop();
                } else {
                  Navigator.push(
                      context,
                      PageRouteBuilder(
                          opaque: false,
                          pageBuilder: (_, __, ___) => const NowPlayingPage()));
                }
              }
              return Future.value(false);
            },
            child: Dismissible(
              key: Key(mediaItem?.id ?? 'nothingPlaying'),
              confirmDismiss: (DismissDirection direction) {
                if (mediaItem != null) {
                  if (direction == DismissDirection.startToEnd) {
                    audioHandler.skipToPrevious();
                  } else {
                    audioHandler.skipToNext();
                  }
                }
                return Future.value(false);
              },
              child: Card(
                margin: const EdgeInsets.symmetric(
                  horizontal: 2.0,
                  vertical: 1.0,
                ),
                elevation: 0,
                child: SizedBox(
                  child: GradientContainer(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        miniplayerTile(
                          context: context,
                          preferredMiniButtons: preferredMiniButtons,
                          useDense: useDense,
                          title: mediaItem?.title ?? '',
                          subtitle: mediaItem?.artist ?? '',
                          imagePath: (isLocal
                              ? mediaItem?.artUri?.toFilePath()
                              : mediaItem?.artUri?.toString()) ??
                              '',
                          isLocalImage: isLocal,
                          isDummy: mediaItem == null,
                        ),
                        positionSlider(
                          mediaItem?.duration?.inSeconds.toDouble(),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  ListTile miniplayerTile({
    required BuildContext context,
    required String title,
    required String subtitle,
    required String imagePath,
    required List preferredMiniButtons,
    bool useDense = false,
    bool isLocalImage = false,
    bool isDummy = false,
  }) {
    return ListTile(
      dense: useDense,
      onTap: isDummy
          ? null
          : () {
        Navigator.push(
            context,
            PageRouteBuilder(
                opaque: false,
                pageBuilder: (_, __, ___) => const NowPlayingPage()));
      },
      title: Text(
        isDummy ? 'Now Playing' : title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        isDummy ? 'Unknown' : subtitle,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      leading: Hero(
        tag: 'currentArtwork',
        child: imageCard(
          elevation: 8,
          boxDimension: useDense ? 40.0 : 50.0,
          localImage: isLocalImage,
          imageUrl: metadata.extras!['artWorkPath'].toString(),
        ),
      ),
      trailing: isDummy
          ? null
          : ControlButtons(
        audioHandler as AudioPlayerHandler,
        miniplayer: true,
        buttons: isLocalImage
            ? ['Like', 'Play/Pause', 'Next']
            : preferredMiniButtons,
      ),
    );
  }


  StreamBuilder<Duration> positionSlider(double? maxDuration) {
    return StreamBuilder<Duration>(
      stream: AudioService.position,
      builder: (context, snapshot) {
        final position = snapshot.data;
        return ((position?.inSeconds.toDouble() ?? 0) < 0.0 ||
            ((position?.inSeconds.toDouble() ?? 0) >
                (maxDuration ?? 180.0)))
            ? const SizedBox()
            : SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: Theme.of(context).colorScheme.secondary,
            inactiveTrackColor: Colors.transparent,
            trackHeight: 0.5,
            thumbColor: Theme.of(context).colorScheme.secondary,
            thumbShape: const RoundSliderThumbShape(
              enabledThumbRadius: 1.0,
            ),
            overlayColor: Colors.transparent,
            overlayShape: const RoundSliderOverlayShape(
              overlayRadius: 2.0,
            ),
          ),
          child: Center(
            child: Slider(
              inactiveColor: Colors.transparent,
              // activeColor: Colors.white,
              value: position?.inSeconds.toDouble() ?? 0,
              max: maxDuration ?? 180.0,
              onChanged: (newPosition) {
                audioHandler.seek(
                  Duration(
                    seconds: newPosition.round(),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
