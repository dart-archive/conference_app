// Copyright (c) 2017, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/material.dart';

// TODO: Show the name and address.

class MapPage extends StatefulWidget {
  static const String title = 'Map';
  static const IconData icon = Icons.map;

  @override
  _MapPageState createState() => new _MapPageState();
}

class _MapPageState extends State<MapPage> {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(MapPage.title),
        automaticallyImplyLeading: false,
      ),
      body: new SizedBox.expand(
        child: new Image.asset(
          'assets/google_la_map.png',
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
