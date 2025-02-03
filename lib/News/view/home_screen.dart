

import 'package:shrayesh_patro/News/view/home_repo_impl.dart';
import 'package:shrayesh_patro/News/view/recommended_news_cubit.dart';
import 'package:shrayesh_patro/News/utils_news/service_locator.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../Backup/gradient_containers.dart';
import '../Source_News/home_main.dart';
import '../Source_News/list-home.dart';
import '../Source_News/list2-home.dart';
import '../Source_News/list3-home.dart';
import '../Source_News/list4-home.dart';
import '../Source_News/list5-home.dart';
import '../Source_News/list6-home.dart';
import '../Source_News/list7-home.dart';
import '../bookmark/bookmark_screen.dart';
import '../utils_news/show_search.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  TabController? _tcontroller;
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (BuildContext context) =>
            RecommendedNewsCubit(getIt.get<HomeRepoImpl>())
              ..fetchRecommendedNews(),
          ),
        ],
        child: SafeArea(
            child: BlocBuilder<RecommendedNewsCubit, RecommendedNewsState>(
                builder: (context, state) {
                  return GradientContainer(
                      child: DefaultTabController(
                        length: 8,
                        child: Scaffold(
                          backgroundColor: Colors.transparent,
                          appBar: AppBar(
                            title: Text(AppLocalizations.of(context)!.news),
                            centerTitle: true,
                            backgroundColor: Theme.of(context).brightness == Brightness.dark
                                ? Colors.transparent
                                : Theme.of(context).colorScheme.secondary,
                            actions: <Widget>[
                              IconButton(
                                padding: const EdgeInsets.only(right: 30),
                                icon: const Icon(Icons.favorite_rounded),
                                iconSize: 30,
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => const BookmarkScreen()),
                                  );
                                },
                              ), //IconButton
                            ],
                            elevation: 0,
                            leading: IconButton(
                              padding: const EdgeInsets.only(left: 20),
                              icon: const Icon(Icons.search, size: 30),
                              onPressed: () {
                                showSearchBar(context);

                              },
                            ),

                            //AppBar//<Widget>[]
                            bottom: TabBar(
                                controller: _tcontroller,
                                tabAlignment: TabAlignment.start,
                                isScrollable: true,
                                 //indicatorColor: Colors.green,
                                // labelColor: Colors.deepOrangeAccent,
                                // unselectedLabelColor: Colors.deepOrangeAccent,
                                tabs: [
                                  Tab(
                                    text: AppLocalizations.of(context)!.latestNews,
                                  ),

                                  Tab(
                                    text: AppLocalizations.of(context)!.technology,
                                  ),
                                  Tab(
                                    text: AppLocalizations.of(context)!.setoPati,
                                  ),
                                  Tab(
                                    text: AppLocalizations.of(context)!.bizmandu,
                                  ),
                                  Tab(
                                    text: AppLocalizations.of(context)!.deshSanchar,
                                  ),
                                  Tab(
                                    text: AppLocalizations.of(context)!.ujyaaloOnline,
                                  ),
                                  Tab(
                                    text: AppLocalizations.of(context)!.onlinekhabar,
                                  ),
                                  Tab(
                                    text: AppLocalizations.of(context)!.bbCNepali,
                                  )
                                ]
                            ),
                          ),

                          body: const TabBarView(
                            physics: NeverScrollableScrollPhysics(),
                            children: <Widget>[
                              HomeMain(),
                              ListHome(),
                              List7Home(),
                              List3Home(),
                              List4Home(),
                              List5Home(),
                              List6Home(),
                              List2Home(),



                            ],
                          ),
                        ),
                      )
                  );
                }
            )
        )
    );


  }
}

