import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class MyImageView extends StatelessWidget {
  final String data;
  final double height;
  final double width;
  final shouldCover;

  MyImageView(this.data, {this.width, this.height, this.shouldCover = true});

  @override
  Widget build(BuildContext context) {
    return data.contains('data:image/png;base64,')
        ? Image.memory(
            base64Decode(data.replaceFirst('data:image/png;base64,', '')),
            fit: shouldCover ? BoxFit.cover : null,
            height: height,
            width: width,
          )
        : CachedNetworkImage(
            fit: shouldCover ? BoxFit.cover : null,
            imageUrl: data,
            errorWidget: (context, url, error) => Icon(Icons.error),
            height: height,
            width: width,
          );
  }
}
