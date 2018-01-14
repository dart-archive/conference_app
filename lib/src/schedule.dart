// Copyright (c) 2017, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'common.dart';

// TODO: Fix the text hero animation.
// TODO: Handle missing images.
// TODO: Determine the complement color for an image.
// TODO: The scroll position isn't being remembered after returning from looking
//       at a specific session.

class SchedulePage extends StatefulWidget {
  static const String title = 'Schedule';
  static const IconData icon = Icons.access_time;

  SchedulePage({Key key}) : super(key: key);

  @override
  _SchedulePageState createState() => new _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  static const int defaultDuration = 30;
  List<Session> allSessions;
  StreamSubscription<QuerySnapshot> sub;

  @override
  void initState() {
    super.initState();

    final CollectionReference collection =
        Firestore.instance.collection('schedules');
    sub = collection?.snapshots?.listen((QuerySnapshot snapshot) {
      setState(() {
        allSessions = snapshot.documents.map(_toSession).toList();
      });
    });
  }

  @override
  void dispose() {
    super.dispose();

    sub?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    if (allSessions == null) {
      return new DefaultTabController(
        length: 2,
        child: new Scaffold(
          appBar: new AppBar(
            title: new Text('DartConf 2018'),
            automaticallyImplyLeading: false,
            bottom: new TabBar(
              tabs: [
                new Tab(text: 'JAN 23'),
                new Tab(text: 'JAN 24'),
              ],
            ),
          ),
          body: new Center(
            child: new CircularProgressIndicator(),
          ),
        ),
      );
    }

    return new DefaultTabController(
      length: 2,
      child: new Scaffold(
        appBar: new AppBar(
          title: new Text('DartConf 2018'),
          automaticallyImplyLeading: false,
          bottom: new TabBar(
            tabs: [
              new Tab(text: 'JAN 23'),
              new Tab(text: 'JAN 24'),
            ],
          ),
        ),
        body: new TabBarView(
          children: [
            buildListForSessions(
              context,
              allSessions
                  .where((Session session) => session.date.day == 23)
                  .toList()
                    ..sort(),
            ),
            buildListForSessions(
              context,
              allSessions
                  .where((Session session) => session.date.day == 24)
                  .toList()
                    ..sort(),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildListForSessions(
      BuildContext context, Iterable<Session> sessions) {
    final List<Session> listSessions = sessions.toList();

    return new ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      itemCount: listSessions.length,
      itemBuilder: (BuildContext context, int index) {
        Session session = listSessions[index];

        if (session.isDivider) {
          return new DividerCardWidget(session);
        } else {
          return new SessionCardWidget(session);
        }
      },
    );
  }

  static Session _toSession(DocumentSnapshot snapshot) {
    DateTime dateTime = snapshot['datetime'] == null
        ? new DateTime(2018, 1, 23)
        : DateTime.parse(snapshot['datetime']);

    return new Session(
      snapshot['title'],
      snapshot['description'],
      dateTime,
      new Duration(minutes: snapshot['duration'] ?? defaultDuration),
      presenters: snapshot['authors'],
      imageUrl: snapshot['image'],
    );
  }
}

class Session implements Comparable<Session> {
  Session(
    this.title,
    this.description,
    this.date,
    this.duration, {
    this.presenters,
    this.imageUrl,
  });

  final String title;

  // nullable
  final String description;

  final DateTime date;

  // nullable
  final Duration duration;
  final String presenters;

  final String imageUrl;

  bool get isDivider =>
      imageUrl == null && description == null && presenters == null;

  String get presentersDescription => presenters ?? '';

  // nullable
  TimeOfDay get time {
    if (date == null) {
      return null;
    }

    return new TimeOfDay(hour: date.hour, minute: date.minute);
  }

  String get id =>
      '${title.replaceAll(' ', '_')}-${date.day}-${time.hour}-${time.minute}';

  String get descriptionParagraphs {
    return description?.replaceAll('.  ', '.\n\n') ?? '';
  }

  String toString() => title;

  @override
  int compareTo(Session other) => date.compareTo(other.date);

  @override
  bool operator ==(other) => other is Session && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

final TextStyle titleStyle =
    const TextStyle(fontSize: 20.0, fontWeight: FontWeight.w600);
final TextStyle dividerTitleStyle =
    const TextStyle(fontSize: 18.0, fontWeight: FontWeight.w600);
final TextStyle detailsStyle =
    const TextStyle(fontWeight: FontWeight.w600, color: Colors.black54);
final TextStyle descStyle = const TextStyle(fontSize: 16.0);
final TextStyle subduedDescStyle =
    const TextStyle(fontSize: 16.0, color: Colors.black54);

class DividerCardWidget extends StatelessWidget {
  DividerCardWidget(this.session);

  final Session session;

  @override
  Widget build(BuildContext context) {
    final Card card = new Card(
      child: new Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          new Padding(
            padding: const EdgeInsets.all(8.0),
            child: new Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                new Text(
                  session.title ?? '',
                  style: dividerTitleStyle,
                  softWrap: false,
                  overflow: TextOverflow.ellipsis,
                ),
                const Divider(),
                new Text(session.time.format(context), style: detailsStyle),
              ],
            ),
          ),
        ],
      ),
    );

    return new Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: card,
    );
  }
}

class SessionCardWidget extends StatelessWidget {
  SessionCardWidget(this.session);

  static final double height = 322.0;

  final Session session;

  @override
  Widget build(BuildContext context) {
    Image image;

    if (session.imageUrl != null) {
      image = new Image.network(
        session.imageUrl,
        fit: BoxFit.cover,
      );
    } else {
      image = new Image.asset(
        'assets/dartconf.png',
        fit: BoxFit.cover,
      );
    }

    final Card card = new Card(
      child: new Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          new Hero(
            tag: 'session/image/${session.id}',
            child: new ConstrainedBox(
              constraints: new BoxConstraints(maxHeight: 200.0),
              child: image,
            ),
          ),
          new Padding(
            padding: const EdgeInsets.all(8.0),
            child: new Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                new Text(
                  session.title ?? '',
                  style: titleStyle,
                  softWrap: false,
                  overflow: TextOverflow.ellipsis,
                ),
                new Text(
                  session.presentersDescription,
                  style: descStyle,
                ),
                const Padding(padding: const EdgeInsets.only(top: 8.0)),
                new Text(
                  session.description ?? '',
                  style: descStyle,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const Divider(),
                new Row(
                  children: <Widget>[
                    new Expanded(
                      child: new Text(session.time.format(context),
                          style: detailsStyle),
                    ),
                    new Text(
                      session.duration == null
                          ? ''
                          : '${session.duration.inMinutes} min',
                      style: detailsStyle,
                    )
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );

    return new GestureDetector(
      onTap: () => showSessionPage(context, session),
      child: new Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: card,
      ),
    );
  }

  void showSessionPage(BuildContext context, Session session) {
    Navigator.push(
      context,
      new MaterialPageRoute<Null>(
        settings: const RouteSettings(name: '/sessions/session'),
        builder: (BuildContext context) {
          return new Theme(
            data: Theme.of(context),
            child: new SessionPage(session),
          );
        },
      ),
    );
  }
}

class SessionPage extends StatelessWidget {
  static final dateFormat = new DateFormat.MMMd();

  final Session session;

  SessionPage(this.session);

  @override
  Widget build(BuildContext context) {
    Image image;

    if (session.imageUrl != null) {
      image = new Image.network(
        session.imageUrl,
        fit: BoxFit.cover,
      );
    } else {
      image = new Image.asset(
        'assets/dartconf.png',
        fit: BoxFit.cover,
      );
    }

    return new Scaffold(
      body: new CustomScrollView(
        slivers: <Widget>[
          new SliverAppBar(
            expandedHeight: 250.0,
            backgroundColor: Colors.transparent,
            flexibleSpace: new FlexibleSpaceBar(
              //title: const Text('Demo'),
              background: new Hero(
                tag: 'session/image/${session.id}',
                child: image,
              ),
            ),
          ),
          new SliverToBoxAdapter(
            child: new Padding(
              padding: new EdgeInsets.all(16.0),
              child: new Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  new Text(
                    session.title,
                    style: titleStyle,
                  ),
                  new Text(
                    session.presentersDescription,
                    style: descStyle,
                  ),
                  new Text(
                    '${dateFormat.format(session.date)}, '
                        '${session.time.format(context)}',
                  ),
                  pad8(),
                  new Text(session.descriptionParagraphs, style: descStyle),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
