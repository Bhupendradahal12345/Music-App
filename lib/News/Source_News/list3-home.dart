

import 'package:shrayesh_patro/News/view/recommended_news_cubit.dart';
import 'package:shrayesh_patro/News/utils_news/service_locator.dart';
import 'package:shrayesh_patro/News/view/home_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'list3_repo_impl.dart';


class List3Home extends StatelessWidget {
  const List3Home({super.key});

  @override
  Widget build(BuildContext context) {


    return MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (BuildContext context) =>
            RecommendedNewsCubit(getIt.get<List3RepoImpl>())
              ..fetchRecommendedNews(),
          ),
        ],
        child: SafeArea(
            child: BlocBuilder<RecommendedNewsCubit, RecommendedNewsState>(
                builder: (context, state) {
                  return RefreshIndicator(
                    onRefresh: () async {
                      await context.read<RecommendedNewsCubit>().fetchRecommendedNews();
                    },


                    child: const RecNewsListView(),
                  );


                }
            )
        )
    );

  }
}

