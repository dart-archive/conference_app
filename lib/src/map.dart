// Copyright (c) 2017, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class MapPage extends StatefulWidget {
  static const String title = 'Map';
  static const IconData icon = Icons.map;

  @override
  _MapPageState createState() => new _MapPageState();
}

class _MapPageState extends State<MapPage> {
  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

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
      floatingActionButton: new Chip(
        label: new InkWell(
          onTap: _launchIntent,
          child: new Padding(
            padding: const EdgeInsets.all(4.0),
            child: new Text(
              'Google Los Angeles\n340 Main St, Venice, CA 90291',
              style: theme.textTheme.subhead.apply(
                  color: Colors.blue, decoration: TextDecoration.underline),
            ),
          ),
        ),
      ),
    );
  }

  Future<Null> _launchIntent() async {
    const url =
        'https://www.google.com/maps/place/Google/@33.9950762,-118.4784572,17z/data=!3m1!4b1!4m5!3m4!1s0x80c2bacf22ee5b65:0x95c465741fbb54b3!8m2!3d33.9950762!4d-118.4762685';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      print("Error: could not launch URL.");
    }
  }
}
