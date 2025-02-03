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
 * along with Shrayesh-Music.  If not, see <http://www.gnu.org/licenses/>.
 *
 * Copyright (c) 2023-2024, Bhupendra Dahal
 */

import 'package:flutter/material.dart';

Widget emptyScreen(
    BuildContext context,
    int turns,
    String text1,
    double size1,
    String text2,
    double size2,
    String text3,
    double size3, {
      bool useWhite = false,
    }) {
  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          RotatedBox(
            quarterTurns: turns,
            child: Text(
              text1,
              textAlign: TextAlign.start,
              style: TextStyle(
                fontSize: size1,
                color: useWhite
                    ? Colors.white
                    : Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w100,
              ),
            ),
          ),
          Column(
            children: [
              Text(
                text2,
                style: TextStyle(
                  fontSize: 20,
                  color: useWhite
                      ? Colors.white
                      : Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w400,
                ),
              ),
              Text(
                text3,
                style: TextStyle(
                  fontSize: size3,
                  fontWeight: FontWeight.w100,
                  color: useWhite ? Colors.white : null,
                ),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
