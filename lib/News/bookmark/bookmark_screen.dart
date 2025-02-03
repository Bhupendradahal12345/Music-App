
import 'package:shrayesh_patro/News/bookmark/bookmark_cubit.dart';
import 'package:shrayesh_patro/News/utils_news/extensions.dart';
import 'package:shrayesh_patro/News/view/BookmarkView.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../view/BookmarkApp.dart';


class BookmarkScreen extends StatelessWidget {
  const BookmarkScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => BookmarkCubit(),
      child: const SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            _BookmarkList(),
          ],
        ),
      ),
    );
  }
}

class _BookmarkList extends StatelessWidget {
  const _BookmarkList();

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverPersistentHeader(
            pinned: false,
            floating: false,
            delegate: PersistentHeader(),
          ),

          SliverFillRemaining(
            child: BlocBuilder<BookmarkCubit, BookmarkState>(
              builder: (context, state) {
                context.read<BookmarkCubit>().getSavedNewsFromStorage();
                if (context.read<BookmarkCubit>().bookmarkedNews.isNotEmpty) {
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount:
                    context.read<BookmarkCubit>().bookmarkedNews.length,
                    itemBuilder: (context, index) {
                      final item = context
                          .read<BookmarkCubit>()
                          .bookmarkedNews[index]
                          .toString();
                      return Dismissible(
                        key: Key(item),
                        direction: DismissDirection.endToStart,
                        onDismissed: (direction) => context
                            .read<BookmarkCubit>()
                            .removeNewsModelFromLocal(context
                            .read<BookmarkCubit>()
                            .bookmarkedNews[index]),
                        background: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(
                            Icons.delete,
                            size: 50,
                          ),
                        ),
                        child: BookmarkView(
                          newsModel: context
                              .read<BookmarkCubit>()
                              .bookmarkedNews[index],
                        ),
                      );
                    },
                  );
                }
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.bookmarks_outlined,
                      size: 50,

                    ),
                    (context.height * 0.02).spaceY,
                    const Text(
                      'कुनै समाचार छैन ',
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.black,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class PersistentHeader extends SliverPersistentHeaderDelegate {
  PersistentHeader();

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return  const BookmarkApp();
  }

  @override
  double get maxExtent => 62;

  @override
  double get minExtent => 62;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
}
