import 'package:equatable/equatable.dart';



class NewsModel extends Equatable {

  final String? source;
  final String? title;
  final String? description;
  final String? link;
  final String? media;
  final String? pubdate;
  final String? profile;

  bool isBookmarked = false;

  NewsModel({

    this.source,
    this.title,
    this.description,
    this.link,
    this.media,
    this.pubdate,
    this.profile,

  });

  Map<String, dynamic> toJson() {
    return <String, dynamic>{

      'source': source,
      'title': title,
      'description': description,
      'link': link,
      'media': media,
      'pubdate': pubdate,
      'profile': profile,

      'isBookmarked': isBookmarked,
    };
  }

  factory NewsModel.fromJson(Map<String, dynamic> json) => NewsModel(

        source: json['source'] as String? ?? 'CNN Indonesia',
        title: json['title'] as String? ?? '',
        description: json['description'] as String? ?? '',
        link: json['link'] as String? ?? '',
        media: json['media'] as String? ?? '',
        pubdate: json['pubdate'] as String? ?? '',
        profile: json['profile'] as String? ?? '',

      );

  @override
  List<Object?> get props {
    return [

      source,
      title,
      description,
      link,
      media,
      pubdate,
      profile,
      isBookmarked,
    ];
  }
}
