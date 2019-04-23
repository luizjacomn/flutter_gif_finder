import 'package:flutter/material.dart';
import 'package:share/share.dart';

class DetailPage extends StatelessWidget {
  final _black = Colors.black;
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
            icon: Icon(_shareIcon),
            onPressed: () {
              Share.share(url);
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
