import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:nepali_utils/nepali_utils.dart';
import 'package:shrayesh_patro/News/bookmark/bookmark_cubit.dart';
import 'package:shrayesh_patro/News/models_news/news_model.dart';
import 'package:shrayesh_patro/News/view/home_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import '../coreComponents/appButton.dart';
import '../coreComponents/fontSize.dart';

class NewsDetailsScreen extends StatelessWidget {
  const NewsDetailsScreen({super.key, required this.newsModel});
  final NewsModel newsModel;

  @override
  Widget build(BuildContext context) {
    var dateValue = DateFormat("EEE, dd MMM y HH:mm:ssz").parseUTC(newsModel.pubdate!).toLocal();
    String formattedDate = DateFormat("yyyy-MM-ddTHH:mm:ssz").format(dateValue);

    return Scaffold(
        body: SafeArea(
          child: Padding(
              padding: const EdgeInsets.all(10),
              child: SingleChildScrollView(
                  child: Column(
                      children: [
                        Row(
                          children: [
                            InkWell(
                              onTap: () => Navigator.pop(context),
                              child: const Icon(
                                Icons.arrow_back_ios_new,
                              ),

                            ),

                          ],
                        ),
                        const SizedBox(height: 10),
                        DecoratedBox(
                          // height: 330,
                          decoration: BoxDecoration(
                            // color: Colors.red,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                  child: ClipRRect(
                                      borderRadius: BorderRadius.circular(20),
                                      child: CachedNetworkImage(
                                        imageUrl: newsModel.media!,
                                        fit: BoxFit.cover,
                                      )
                                  )

                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          newsModel.title!,
                          style: const TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Row(
                          children: [
                            BlocBuilder<BookmarkCubit, BookmarkState>(
                              builder: (context, state) {
                                return CustomIconButton(
                                  onTap: () {
                                    context.read<BookmarkCubit>().addToBookmarked(newsModel);
                                  },
                                  child: Icon(
                                    newsModel.isBookmarked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                                    color: newsModel.isBookmarked ? Theme.of(context).colorScheme.secondary : Theme.of(context).colorScheme.primary,
                                    size: 30,
                                  ),
                                );
                              },
                            ),

                            const SizedBox(width: 10),
                            SizedBox(
                              height: 40,
                              width: 40,
                              child: ClipRRect(

                                borderRadius: BorderRadius.circular(20),
                                child: Image.network(
                                    newsModel.profile!,
                                    fit:BoxFit.fill

                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              '${newsModel.source}  - ${NepaliMoment.fromAD(DateTime.parse(formattedDate))}',
                              style: TextStyle(
                                fontWeight: FontWeight.w400,
                                fontSize: 18,
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                newsModel.description ?? 'कुनै विवरण छैन',
                                style: const TextStyle(
                                  fontSize: 18,
                                ),
                              ),
                            ),
                          ],
                        ),
                        AppButton(
                          onTap: () =>
                              launchUrl(Uri.parse(newsModel.link!)),
                          label: '${NepaliMoment.fromAD(DateTime.parse(formattedDate))} • ${"पुरा समचार.... "}',
                          margin: const EdgeInsets.only(top: S.s40),


                        )
                      ]
                  )

              )
          ),
        )
    );

  }
}

