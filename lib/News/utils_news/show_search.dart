import 'package:shrayesh_patro/News/view/home_repo_impl.dart';
import 'package:shrayesh_patro/News/search_cubit/search_cubit_cubit.dart';
import 'package:shrayesh_patro/News/utils_news/error_widget.dart';
import 'package:shrayesh_patro/News/utils_news/service_locator.dart';
import 'package:shrayesh_patro/News/view/home_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


Future<void> showSearchBar(BuildContext context) async {
  await showSearch(
    context: context,
    delegate: CustomSearchDelegate(),
  );
}

class CustomSearchDelegate extends SearchDelegate {
  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        onPressed: () {
          const RecNewsListView();
        },
        icon: const Icon(Icons.clear),
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () {
        close(context, null);
      },
      icon: const Icon(Icons.arrow_back),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          SearchCubit(getIt.get<HomeRepoImpl>())..search(query),
      child: BlocBuilder<SearchCubit, SearchState>(
        builder: (context, state) {
          if (state is SearchSuccessState) {
            return ListView.builder(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              itemCount: state.news.length,
              itemBuilder: (context, index) {
                return RecNewsItem(
                  newsModel: state.news[index],
                );
              },
            );
          } else if (state is SearchFailureState) {
            return ErrorItem(
              message: state.errMessage,
            );
          } else {
            return const LinearProgressIndicator();
          }
        },
      ),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return Container();
  }
}
