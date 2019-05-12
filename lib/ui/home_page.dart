import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gif_finder/ui/detail_page.dart';
import 'package:http/http.dart' as http;
import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'package:transparent_image/transparent_image.dart';


class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _black = Colors.black;
  final _white = Colors.white;
  final _yellow = Colors.yellow;

  final _img = 'images/logo.gif';
  final _moreIcon = Icons.add;

  final _dataKey = 'data';
  final _imagesKey = 'images';
  final _aspectKey = 'fixed_height';
  final _imageUrlKey = 'url';

  final _baseUri = 'https://api.giphy.com/v1/gifs';
  final _apiKey = 'r8SCCDxUqmSaEqSEgXEzHqSdLJyGjcWp';
  final _rating = 'G';
  final _language = 'en';
  int _offset = 0;
  String _search;

  bool _isSearching() {
    return !_isNotSearching();
  }

  bool _isNotSearching() {
    return _search == null;
  }

  Future<Map> _getGifs() async {
    http.Response response;

    if (_isSearching())
      response = await http.get(
          '$_baseUri/search?api_key=$_apiKey&q=$_search&limit=19&offset=$_offset&rating=$_rating&lang=$_language');
    else
      response = await http
          .get('$_baseUri/trending?api_key=$_apiKey&limit=20&rating=$_rating');

    return json.decode(response.body);
  }

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.blueGrey[400], // status bar color
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _black,
      appBar: AppBar(
        backgroundColor: _black,
        title: Padding(
          padding: EdgeInsets.only(top: 10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Image.asset(
                _img,
                fit: BoxFit.cover,
                height: 1000.0,
              ),
              Text(
                'Gif Finder',
                style: TextStyle(color: _yellow, fontSize: 25.0),
              )
            ],
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(
                left: 10.0, right: 10.0, bottom: 20.0, top: 10.0),
            child: TextField(
              style: TextStyle(color: _white, fontSize: 20.0),
              textInputAction: TextInputAction.search,
              onSubmitted: (text) {
                setState(() {
                  _search = text;
                  _offset = 0;
                });
              },
              decoration: InputDecoration(
                  labelText: 'Buscar Gifs',
                  labelStyle: TextStyle(color: _white),
                  border: OutlineInputBorder()),
            ),
          ),
          Expanded(
            child: FutureBuilder(
                future: _getGifs(),
                builder: (context, snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.waiting:
                    case ConnectionState.none:
                      return Container(
                        width: 200.0,
                        height: 200.0,
                        alignment: Alignment.center,
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation(_white),
                          strokeWidth: 5.0,
                        ),
                      );
                    default:
                      if (snapshot.hasError) return Container();

                      if (!snapshot.hasError)
                        return _createGifGrid(context, snapshot);
                  }
                }),
          )
        ],
      ),
    );
  }

  int _getCount(List data) => _isSearching() ? data.length + 1 : data.length;

  Widget _createGifGrid(BuildContext context, AsyncSnapshot snapshot) {
    return GridView.builder(
        padding: EdgeInsets.all(10.0),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, crossAxisSpacing: 10.0, mainAxisSpacing: 10.0),
        itemCount: _getCount(snapshot.data[_dataKey]),
        itemBuilder: (context, index) {
          if (_isNotSearching() || index < snapshot.data[_dataKey].length) {
            final url = snapshot.data[_dataKey][index][_imagesKey][_aspectKey]
                [_imageUrlKey];

            return GestureDetector(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            DetailPage(snapshot.data[_dataKey][index])));
              },
              onLongPress: () async {
                var request = await HttpClient().getUrl(Uri.parse(url));
                var response = await request.close();
                Uint8List bytes = await consolidateHttpClientResponseBytes(response);
                await Share.file('Gif from Gif Finder', 'gif-finder.gif', bytes, 'image/gif');
              },
              child: FadeInImage.memoryNetwork(
                placeholder: kTransparentImage,
                image: url,
                height: 300.0,
                fit: BoxFit.cover,
              ),
            );
          } else {
            return Container(
              child: GestureDetector(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(
                      _moreIcon,
                      color: _yellow,
                      size: 60.0,
                    ),
                    Text(
                      'Carregar mais...',
                      style: TextStyle(color: _yellow, fontSize: 20.0),
                    )
                  ],
                ),
                onTap: () {
                  setState(() {
                    _offset += 19;
                  });
                },
              ),
            );
          }
        });
  }
}
