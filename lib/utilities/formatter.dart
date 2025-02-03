
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

String formatSongTitle(String title) {
  final wordsPattern = RegExp(
    r'\b(official music video|official lyric video|official lyrics video|official video|official 4k video|official audio|lyric video|lyrics video|official hd video|lyric visualizer|lyric vizualizer|official visualizer|lyrics|lyric)\b',
    caseSensitive: false,
  );

  final replacements = {
    '[': '',
    ']': '',
    '(': '',
    ')': '',
    '|': '',
    '&amp;': '&',
    '&#039;': "'",
    '&quot;': '"',
  };

  final pattern = RegExp(replacements.keys.map(RegExp.escape).join('|'));

  var finalTitle = title
      .replaceAllMapped(
    pattern,
        (match) => replacements[match.group(0)] ?? '',
  )
      .trimLeft();

  finalTitle = finalTitle.replaceAll(wordsPattern, '');

  return finalTitle;
}

Map<String, dynamic> returnSongLayout(int index, Video song) => {
  'id': index,
  'ytid': song.id.toString(),
  'title': formatSongTitle(
    song.title.split('-')[song.title.split('-').length - 1],
  ),
  'artist': song.title.split('-')[0],
  'image': song.thumbnails.standardResUrl,
  'lowResImage': song.thumbnails.lowResUrl,
  'highResImage': song.thumbnails.maxResUrl,
  'duration': song.duration?.inSeconds,
  'isLive': song.isLive,
  'uploadDateRaw': song.uploadDateRaw,
  'author': song.author,
};

String formatDuration(int audioDurationInSeconds) {
  final duration = Duration(seconds: audioDurationInSeconds);

  final hours = duration.inHours;
  final minutes = duration.inMinutes.remainder(60);
  final seconds = duration.inSeconds.remainder(60);

  var formattedDuration = '';

  if (hours > 0) {
    formattedDuration += '${hours.toString().padLeft(2, '0')}:';
  }

  formattedDuration += '${minutes.toString().padLeft(2, '0')}:';
  formattedDuration += seconds.toString().padLeft(2, '0');

  return formattedDuration;
}
