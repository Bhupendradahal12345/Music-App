import 'package:shrayesh_patro/News/view/rec_news.dart';
import 'package:shrayesh_patro/News/view/recommended_news_cubit.dart';
import 'package:shrayesh_patro/News/utils_news/error_widget.dart';
import 'package:shrayesh_patro/News/view/home_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RecNewsList extends StatelessWidget {
  const RecNewsList({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RecommendedNewsCubit, RecommendedNewsState>(

      builder: (context, state) {
        if (state is RecommendedNewsSuccessState) {
          return ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: state.news.length,
            padding: EdgeInsets.zero,
            itemBuilder: (BuildContext context, int index) {
              return RecNews(
                newsModel: state.news[index],
              );
            },
          );
        } else if (state is RecommendedNewsFailureState) {
          return ErrorItem(
            message: state.errMessage,
          );
        } else {
          return const RecNewsLoading();
        }
      },
    );

  }
}
