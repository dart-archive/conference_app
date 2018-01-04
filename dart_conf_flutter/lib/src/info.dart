// Copyright (c) 2017, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'common.dart';

// TODO: Add a link to a dartconf gitter room.

class InfoPage extends StatefulWidget {
  static const String title = 'Info';
  static const IconData icon = Icons.info_outline;

  @override
  _InfoPageState createState() => new _InfoPageState();
}

class _InfoPageState extends State<InfoPage> {
  List<InfoData> infos;

  @override
  void initState() {
    super.initState();

    final CollectionReference collection =
        Firestore.instance.collection('info');
    collection?.snapshots?.listen((QuerySnapshot snapshot) {
      setState(() {
        infos = snapshot.documents.map(InfoData.fromDocument).toList();
        infos.sort();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    Widget body;

    if (infos == null) {
      body = new Center(
        child: new CircularProgressIndicator(),
      );
    } else {
      var _textToExpansionTile = (InfoData info) {
        return new ExpansionTile(
          title: new Text(info.title),
          key: new PageStorageKey<String>(info.title),
          children: <Widget>[
            new Text(info.text, style: theme.textTheme.subhead),
          ].map(_pad).toList(),
        );
      };

      body = new ListView(
        children: infos.map(_textToExpansionTile).toList(),
      );
    }

    return new Scaffold(
      appBar: new AppBar(title: new Text('DartConf 2018')),
      body: body,
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

class InfoData implements Comparable<InfoData> {
  static InfoData fromDocument(DocumentSnapshot doc) {
    return new InfoData(doc['title'], addParagraphs(doc['text']), doc['order']);
  }

  final String title;
  final String text;
  final int order;

  InfoData(this.title, this.text, this.order);

  @override
  int compareTo(InfoData other) {
    if (order == other.order) {
      return title.compareTo(other.title);
    } else {
      return order - other.order;
    }
  }
}
