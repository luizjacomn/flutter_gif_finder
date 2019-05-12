import 'package:flutter/material.dart';
import 'package:flutter_gif_finder/ui/home_page.dart';

void main() {
  runApp(MaterialApp(
    home: HomePage(),
    title: 'Gif Finder',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      primarySwatch: Colors.yellow,
      hintColor: Colors.white
    ),
  ));
}