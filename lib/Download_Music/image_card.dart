/*
 *  This file is part of Shrayesh-Music (https://bhupendra12345678.github.io/mymusic/).
 *
 * Shrayesh-Music is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * Shrayesh_music is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with Shrayesh_music.  If not, see <http://www.gnu.org/licenses/>.
 *
 * Copyright (c) 2023-2024, Bhupendra Dahal
 */

import 'dart:io';


import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shrayesh_patro/Download_Music/url_image_generator.dart';

import 'image_quality.dart';

Widget imageCard({
  required String imageUrl,
  bool localImage = false,
  double elevation = 5,
  EdgeInsetsGeometry margin = EdgeInsets.zero,
  double borderRadius = 7.0,
  double? boxDimension = 55.0,
  ImageProvider placeholderImage = const AssetImage(
    'assets/cover.jpg',
  ),
  bool selected = false,
  ImageQuality imageQuality = ImageQuality.low,
  Function(Object, StackTrace?)? localErrorFunction,
}) {
  return Card(
    elevation: elevation,
    margin: margin,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(borderRadius),
    ),
    clipBehavior: Clip.antiAlias,
    child: SizedBox.square(
      dimension: boxDimension,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (localImage || imageUrl == '')
            Image(
              fit: BoxFit.cover,
              errorBuilder: (context, error, stacktrace) {
                if (localErrorFunction != null) {
                  localErrorFunction(error, stacktrace);
                }
                return Image(
                  fit: BoxFit.cover,
                  image: placeholderImage,
                );
              },
              image: FileImage(
                File(
                  imageUrl,
                ),
              ),
            )
          else
            CachedNetworkImage(
              fit: BoxFit.cover,
              errorWidget: (context, _, __) => Image(
                fit: BoxFit.cover,
                image: placeholderImage,
              ),
              imageUrl:
              UrlImageGetter([imageUrl]).getImageUrl(quality: imageQuality),
              placeholder: (context, url) => Image(
                fit: BoxFit.cover,
                image: placeholderImage,
              ),
            ),
          if (selected)
            Container(
              decoration: const BoxDecoration(
                color: Colors.black54,
              ),
              child: const Center(
                child: Icon(
                  Icons.check_rounded,
                ),
              ),
            ),
        ],
      ),
    ),
  );
}
