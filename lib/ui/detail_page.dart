import 'dart:io';
import 'dart:typed_data';

import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class DetailPage extends StatelessWidget {
  final _black = Colors.black;
  final _yellow = Colors.yellow;
  final Map _gifData;

  final _imagesKey = 'images';
  final _aspectKey = 'fixed_height';
  final _imageUrlKey = 'url';
  final _titleKey = 'title';
  final _shareIcon = Icons.share;

  DetailPage(this._gifData);

  @override
  Widget build(BuildContext context) {
    final url = _gifData[_imagesKey][_aspectKey][_imageUrlKey];

    return Scaffold(
      backgroundColor: _black,
      appBar: AppBar(
        title: Text(_gifData[_titleKey]),
        backgroundColor: _black,
        actions: <Widget>[
          IconButton(
            tooltip: 'Compartilhar',
            icon: Icon(
              _shareIcon,
              color: _yellow,
            ),
            onPressed: () async {
              var request = await HttpClient().getUrl(Uri.parse(url));
              var response = await request.close();
              Uint8List bytes = await consolidateHttpClientResponseBytes(response);
              await Share.file('Gif from Gif Finder', 'gif-finder.gif', bytes, 'image/gif');
            },
          )
        ],
      ),
      body: Center(
        child: Image.network(url),
      ),
    );
  }
}
