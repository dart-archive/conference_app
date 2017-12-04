// Copyright (c) 2017, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/material.dart';

// TODO: Add a link to a dartconf gitter room.
// TODO: Populate information about the lightning talks and unconference sessions.

class InfoPage extends StatefulWidget {
  static const String title = 'Info';
  static const IconData icon = Icons.info_outline;

  @override
  _InfoPageState createState() => new _InfoPageState();
}

final List<String> sections = [
  '''General

DartConf is a two day event held on January 23rd and 24th, 2018. DartConf is the premier event that connects Flutter and AngularDart developers together, and to the Google engineers who work on these projects.

The conference is single tracked with short, engaging presentations, and has an evening event the first night.

DartConf talks will be live streamed, recorded, and uploaded to the Google Developer channel on YouTube.
''',
  '''Lightning talks

TODO: Tues night
''',
  '''Unconference sessions

TODO: Wed. night
''',
  '''Venue

The Dart Conference will take place at the Google Los Angeles campus, just 5 minutes walk from Venice Beach.

The Google LA campus features the iconic, Frank Gehry-designed Binoculars Building.

Google Los Angeles
320 Hampton Dr, Venice, CA 90291  
''',
  '''Accommodations

We recommend Le Méridien Delfina Santa Monica:

(310) 399-9344

530 Pico Boulevard
Santa Monica, CA 90405, United States
''',
];

class _InfoPageState extends State<InfoPage> {
  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    var _textToExpansionTile = (String text) {
      final String title = text.split('\n').first;
      text = text.split('\n').skip(1).join('\n').trim();

      return new ExpansionTile(
        title: new Text(title),
        key: new PageStorageKey<String>(title),
        children: <Widget>[
          new Text(text, style: theme.textTheme.subhead),
        ].map(_pad).toList(),
      );
    };

    return new Scaffold(
      appBar: new AppBar(title: new Text('DartConf 2018')),
      body: new ListView(
        children: sections.map(_textToExpansionTile).toList(),
      ),
    );
  }
}

Widget _pad(Widget child) {
  return new Padding(
    padding: const EdgeInsets.only(
      left: 16.0,
      right: 16.0,
      bottom: 16.0,
    ),
    child: child,
  );
}
