/*
 *  This file is part of Shrayesh-Music (https://bhupendra12345678.github.io/mymusic/).
 *
 * Shrayesh-Music is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * Shrayesh-Music is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with Shrayesh_music.  If not, see <http://www.gnu.org/licenses/>.
 *
 * Copyright (c) 2023-2024, Bhupendra Dahal
 */

import 'dart:math';

import 'package:shrayesh_patro/Extra/textinput-dilog.dart';
import 'package:shrayesh_patro/screens/home_page.dart';
import 'package:shrayesh_patro/screens/search_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';



class Downloadhome extends StatefulWidget {
  const Downloadhome({
    super.key,
  });

  @override
  State<Downloadhome> createState() => _DownloadhomeState();
}

class _DownloadhomeState extends State<Downloadhome> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var name =
    Hive.box('settings').get('name', defaultValue: 'Shrayesh_music') as String;
    final screenWidth = MediaQuery.sizeOf(context).width;
    final rotated = MediaQuery.sizeOf(context).height < screenWidth;
    return SafeArea(
      child: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                NestedScrollView(
                  physics: const BouncingScrollPhysics(),
                  controller: _scrollController,
                  headerSliverBuilder: (
                      BuildContext context,
                      bool innerBoxScrolled,
                      ) {
                    return <Widget>[
                      SliverAppBar(
                        expandedHeight: 1,
                        backgroundColor: Colors.transparent,
                        elevation: 0,
                        // pinned: true,
                        toolbarHeight: 15,
                        // floating: true,
                        automaticallyImplyLeading: false,
                        flexibleSpace: LayoutBuilder(
                          builder: (
                              BuildContext context,
                              BoxConstraints constraints,
                              ) {
                            return FlexibleSpaceBar(
                              titlePadding: EdgeInsets.zero,
                              // collapseMode: CollapseMode.parallax,
                              background: GestureDetector(
                                onTap: () async {
                                  showTextInputDialog(
                                    context: context,
                                    title: 'Name',
                                    initialText: name,
                                    keyboardType: TextInputType.name,
                                    onSubmitted:
                                        (String value, BuildContext context) {
                                      Hive.box('settings').put(
                                        'name',
                                        value.trim(),
                                      );
                                      name = value.trim();
                                      Navigator.pop(context);
                                    },
                                  );
                                  // setState(() {});
                                },
                              ),
                            );
                          },
                        ),
                      ),

                      SliverAppBar(
                        automaticallyImplyLeading: false,
                        pinned: true,
                        backgroundColor: Colors.transparent,
                        elevation: 0,
                        stretch: true,
                        toolbarHeight: 45,
                        //searchbar height //
                        title: Align(
                          alignment: Alignment.centerRight,
                          child: AnimatedBuilder(
                            animation: _scrollController,
                            builder: (context, child) {
                              return GestureDetector(
                                child: AnimatedContainer(
                                  width: (!_scrollController.hasClients ||
                                      _scrollController.positions.length > 1)
                                      ? MediaQuery.sizeOf(context).width
                                      : max(
                                    MediaQuery.sizeOf(context).width -
                                        _scrollController.offset
                                            .roundToDouble(),
                                    MediaQuery.sizeOf(context).width -
                                        (rotated ? 0 : 75),
                                  ),
                                  height: 45,
                                  //searchbar height //
                                  duration: const Duration(
                                    milliseconds: 150,
                                  ),
                                  padding: const EdgeInsets.all(2),
                                  // margin: EdgeInsets.zero,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(
                                      12,
                                    ),
                                    color: Theme.of(context).cardColor,
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Colors.black26,
                                        blurRadius: 5,
                                        offset: Offset(1.5, 1.5),
                                        // shadow direction: bottom right
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    children: [
                                      const SizedBox(
                                        width: 10,

                                      ),
                                      Icon(
                                        CupertinoIcons.search,
                                        size: 30,
                                        color:
                                        Theme.of(context).colorScheme.secondary,
                                      ),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      Text(
                                        AppLocalizations.of(
                                          context,
                                        )!
                                            .search,
                                        style: TextStyle(
                                          fontSize: 20,
                                          color: Theme.of(context)
                                              .textTheme
                                              .bodySmall!
                                              .color,
                                          fontWeight: FontWeight.normal,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const SearchPage(

                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ];
                  },
                  body:  const HomePage(),
                ),


              ],
            ),
          ),

        ],
      ),
    );
  }
}
