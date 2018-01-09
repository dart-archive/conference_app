// Copyright (c) 2017, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'src/common.dart';
import 'src/feeds.dart';
import 'src/info.dart';
import 'src/map.dart';
import 'src/schedule.dart';

Future main() async {
  await initializeDateFormatting('en');

  runApp(new DartConfApp());
}

class DartConfApp extends StatefulWidget {
  @override
  DartConfAppState createState() {
    return new DartConfAppState();
  }
}

class DartConfAppState extends State<DartConfApp> {
  static const Curve scrollCurve = Curves.fastOutSlowIn;
  static final Key key = new UniqueKey();

  final PageController controller = new PageController();

  int _selectedIndex = 0;
  final Key feedPageKey = new GlobalKey(debugLabel: 'feed page');

  @override
  Widget build(BuildContext context) {
    final Color textColor = appTheme.textTheme.body1.color;
    final TextStyle textStyle = new TextStyle(color: textColor);

    return new MaterialApp(
      title: 'DartConf',
      theme: appTheme,
      home: new Scaffold(
        body: new PageView(
          controller: controller,
          children: <Widget>[
            new SchedulePage(key: key),
            new InfoPage(),
            new MapPage(),
            new FeedsPage(),
          ],
        ),
        bottomNavigationBar: new BottomNavigationBar(
          type: BottomNavigationBarType.shifting,
          currentIndex: _selectedIndex,
          onTap: (int index) {
            setState(() {
              _selectedIndex = index;
              controller.animateToPage(
                _selectedIndex,
                duration: kTabScrollDuration,
                curve: scrollCurve,
              );
            });
          },
          items: <BottomNavigationBarItem>[
            new BottomNavigationBarItem(
              icon: new Icon(SchedulePage.icon, color: textColor),
              title: new Text(SchedulePage.title, style: textStyle),
              backgroundColor: appTheme.secondaryHeaderColor,
            ),
            new BottomNavigationBarItem(
              icon: new Icon(InfoPage.icon, color: textColor),
              title: new Text(InfoPage.title, style: textStyle),
              backgroundColor: appTheme.secondaryHeaderColor,
            ),
            new BottomNavigationBarItem(
              icon: new Icon(MapPage.icon, color: textColor),
              title: new Text(MapPage.title, style: textStyle),
              backgroundColor: appTheme.secondaryHeaderColor,
            ),
            new BottomNavigationBarItem(
              icon: new Icon(FeedsPage.icon, color: textColor),
              title: new Text(FeedsPage.title, style: textStyle),
              backgroundColor: appTheme.secondaryHeaderColor,
            ),
          ],
        ),
      ),
    );
  }
}
