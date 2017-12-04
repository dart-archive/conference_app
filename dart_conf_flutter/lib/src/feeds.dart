// Copyright (c) 2017, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

// TODO: Errors don't complete the future / spinner.
// TODO: New entries should animate in.
// TODO: Periodically refresh the feed info.
// TODO: We'll need to be aware of the default client rate limit (450).

final FeedManager feedManager = new FeedManager();

class FeedsPage extends StatefulWidget {
  static const String title = 'Feeds';
  static const IconData icon = Icons.rss_feed;

  @override
  _FeedsPageState createState() => new _FeedsPageState();
}

class _FeedsPageState extends State<FeedsPage> {
  bool _disposed = false;

  @override
  void initState() {
    super.initState();

    if (feedManager.feeds == null) {
      feedManager.load(context).then((_) {
        if (!_disposed) {
          setState(() {
            //
          });
        }
      });
    }
  }

  @override
  void dispose() {
    super.dispose();

    _disposed = true;
  }

  @override
  Widget build(BuildContext context) {
    Widget body;

    if (feedManager.error != null) {
      return new Scaffold(
        appBar: new AppBar(
          title: new Text(FeedsPage.title),
          automaticallyImplyLeading: false,
        ),
        body: new Center(child: new Text(feedManager.error)),
      );
    } else if (feedManager.feeds == null) {
      body = new Center(
        child: new CircularProgressIndicator(),
      );
    } else {
      body = new ListView.builder(
        padding: const EdgeInsets.only(top: 8.0),
        itemCount: feedManager.feeds.length,
        itemBuilder: (BuildContext context, int index) {
          return new FeedWidget(feedManager.feeds[index]);
        },
      );
    }

    return new Scaffold(
      appBar: new AppBar(
        title: new Text(FeedsPage.title),
        automaticallyImplyLeading: false,
      ),
      body: new RefreshIndicator(
        onRefresh: () {
          return feedManager.refresh(context).then((_) {
            setState(() {
              //
            });
          });
        },
        child: body,
      ),
    );
  }
}

class FeedWidget extends StatelessWidget {
  static final TextStyle authorStyle = const TextStyle(
    fontSize: 16.0,
    fontWeight: FontWeight.w500,
  );
  static final TextStyle dateStyle = const TextStyle(
    fontSize: 16.0,
    fontWeight: FontWeight.w300,
  );
  static final TextStyle descStyle = const TextStyle(fontSize: 16.0);

  final Feed feed;

  FeedWidget(this.feed) : super(key: new ObjectKey(feed.id_str));

  @override
  Widget build(BuildContext context) {
    final CircleAvatar avatar =
        new CircleAvatar(child: new Text(feed.avatarText));

    return new Container(
      padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
      child: new GestureDetector(
        onTap: () {
          final String url = feed.urls.isEmpty ? null : feed.urls.first;
          print(url);
          if (url != null) {
            launch(url);
          }
        },
        child: new Material(
          type: MaterialType.card,
          elevation: 2.0,
          child: new Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              new Padding(
                padding: const EdgeInsets.all(8.0),
                child: new Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    new Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        avatar,
                        _pad(),
                        new Expanded(
                          child: new Column(
                            children: <Widget>[
                              new Row(
                                children: <Widget>[
                                  new Expanded(
                                    child: new Text(
                                      '@${feed.user}' ?? '',
                                      style: authorStyle,
                                    ),
                                  ),
                                  _pad(),
                                  new Text(
                                    feed.createdAtDescription ?? '',
                                    style: dateStyle,
                                  ),
                                ],
                              ),
                              const Padding(padding: const EdgeInsets.all(2.0)),
                              new Text(feed.text, style: descStyle),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Padding _pad() => const Padding(padding: const EdgeInsets.all(4.0));

// TODO: Use the 'indices' info to highlight ranges in the message.
// TODO: Display retweet_count? favorites_count?

class Feed implements Comparable<Feed> {
  static DateFormat twitterDateFormat =
      new DateFormat('EEE MMM dd HH:mm:ss ZZZZZ yyyy', 'en');

  static Feed parse(dynamic json) {
    // FormatException: Invalid date format "Sat Dec 02 22:46:21 +0000 2017"
    // String twitterFormat="EEE MMM dd HH:mm:ss ZZZZZ yyyy"
    return new Feed(
      id_str: json['id_str'],
      user: json['user']['screen_name'],
      text: json['text'],
      // TODO: Fix date parsing.
      //created_at: twitterDateFormat.parse(json['created_at']),
      created_at: new DateTime.now(),
      hashtags: json['entities']['hashtags'].map((h) => h['text']).toList(),
      user_mentions: json['entities']['user_mentions']
          .map((h) => h['screen_name'])
          .toList(),
      urls: json['entities']['urls'].map((u) => u['url']).toList(),
    );
  }

  // These field names are deliberately kept the same as the twitter feed API.

  final String id_str; // ignore: non_constant_identifier_names
  final String user;
  final String text;
  final List<String> hashtags;
  final List<String> user_mentions; // ignore: non_constant_identifier_names
  final List<String> urls;
  final DateTime created_at; // ignore: non_constant_identifier_names

  Feed({
    this.id_str, // ignore: non_constant_identifier_names
    this.user,
    this.text,
    this.created_at, // ignore: non_constant_identifier_names
    this.hashtags: const [],
    this.user_mentions: const [], // ignore: non_constant_identifier_names
    this.urls: const [],
  });

  String get avatarText => user.substring(0, 1).toUpperCase();

  @override
  bool operator ==(other) => other is Feed && id_str == other.id_str;

  @override
  int get hashCode => id_str.hashCode;

  static DateFormat dateFormat = new DateFormat('LLL d');
  static DateFormat timeFormat = new DateFormat.jm();

  String get createdAtDescription {
    // TODO: If today, show the time; else show the date.
    return '${dateFormat.format(created_at)} ${timeFormat.format(created_at)}';
  }

  String get taggedDescription {
    return hashtags.map((h) => '#$h').join(' ');
  }

  @override
  int compareTo(Feed other) {
    // TODO: Do we need to reverse the comparison order?
    return this.created_at.compareTo(other.created_at);
  }
}

// TODO: Move to a separate library.

class FeedManager {
  final http.Client httpClient = createHttpClient();

  List<Feed> feeds;
  String error;

  Future _loadFuture;
  String _bearerToken;

  FeedManager();

  Future load(BuildContext context) async {
    if (_loadFuture != null) {
      return _loadFuture;
    }

    _loadFuture = _load(context);

    _loadFuture.whenComplete(() {
      _loadFuture = null;
    });

    return _loadFuture;
  }

  // TODO: This context will get out of date; we instead need to query a global
  // key for the FeedPage for the current state associated with it, if any.
  Future _load(BuildContext context) async {
    final Future<String> bundleData =
        rootBundle.loadString('assets/app.token.txt');
    final String token = (await bundleData)?.trim();

    http.Response response;

    try {
      response = await httpClient.post(
        'https://api.twitter.com/oauth2/token',
        body: 'grant_type=client_credentials',
        headers: {
          'Authorization': 'Basic $token',
          'Content-Type': 'application/x-www-form-urlencoded;charset=UTF-8',
        },
      );
    } catch (e) {
      showSnackBar(context, '$e');
      return;
    }

    dynamic json;

    try {
      final String accessTokenData = response.body;
      json = JSON.decode(accessTokenData);
    } catch (e) {
      showSnackBar(context, '$e');
      return;
    }

    if (json is! Map) {
      showSnackBar(context, 'Unexpected response from server.');
      return;
    }

    // either:
    //   {"token_type":"bearer","access_token":"..."}
    // or:
    //   {"errors":[{"code":99,"message":"Unable to verify your credentials","label":"authenticity_token_error"}]}
    Map m = json;

    if (m.containsKey('errors')) {
      dynamic errors = m['errors'];
      String errorMessage;
      try {
        errorMessage = errors[0]['message'];
      } catch (e) {
        errorMessage = '$errors';
      }

      showSnackBar(context, errorMessage);
    } else {
      try {
        _bearerToken = m['access_token'];

        await _query(context);
      } catch (e) {
        showSnackBar(context, '$e');
      }
    }
  }

  Future _query(BuildContext context) async {
    final String searchQuery = Uri.encodeComponent('#dartconf OR #flutterio');

    http.Response response;

    try {
      response = await httpClient.get(
        'https://api.twitter.com/1.1/search/tweets.json?q=$searchQuery',
        headers: {
          'Authorization': 'Bearer $_bearerToken',
          'Content-Type': 'application/x-www-form-urlencoded;charset=UTF-8',
        },
      );
    } catch (e) {
      showSnackBar(context, '$e');
      return;
    }

    // TODO: Handle errors.
    dynamic result = json.decode(response.body);

    int rateLimit = int.parse(response.headers['x-rate-limit-limit'] ?? '0');
    int limitRemaining =
        int.parse(response.headers['x-rate-limit-remaining'] ?? '0');
    int limitReset = int.parse(response.headers['x-rate-limit-reset'] ?? '0');
    int secondsLeft =
        (limitReset ?? 0) - (new DateTime.now().millisecondsSinceEpoch ~/ 1000);
    // Log the headers for the rate limiting.
    print('rate limit $limitRemaining / $rateLimit (reset in ${secondsLeft}s)');

    List<Feed> items = (result['statuses'] as List).map(Feed.parse).toList();
    items.sort();
    this.feeds = items;
  }

  void showSnackBar(BuildContext context, String text) {
    final ScaffoldState scaffoldState = Scaffold.of(context);
    scaffoldState.showSnackBar(new SnackBar(content: new Text(text)));
  }

  Future refresh(BuildContext context) async {
    await _query(context);
  }
}
