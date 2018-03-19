// Copyright (c) 2017, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:convert' as convert show json;
import 'dart:developer' show log;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

// TODO: New entries should animate in (see AnimatedList).
// TODO: Periodically refresh the feed info.
// TODO: We'll need to be aware of the default client rate limit (450).

final FeedManager feedManager = new FeedManager();

const String searchQuery = '#dartconf OR #flutterio OR #angulardart';

class FeedsPage extends StatefulWidget {
  static const String title = 'Feeds';
  static const IconData icon = Icons.rss_feed;

  @override
  _FeedsPageState createState() => new _FeedsPageState();
}

class _FeedsPageState extends State<FeedsPage> {
  bool _disposed = false;

  List<Feed> feeds;
  StreamSubscription sub;

  @override
  void initState() {
    super.initState();

    this.feeds = feedManager.feeds;

    feedManager.onFeedsChanged.listen((feeds) {
      if (!_disposed) {
        setState(() {
          this.feeds = feeds;
        });
      }
    });
  }

  @override
  void dispose() {
    super.dispose();

    sub?.cancel();

    _disposed = true;
  }

  @override
  Widget build(BuildContext context) {
    Widget body;

    if (feedManager.feeds == null) {
      feedManager.load().catchError((e) {
        if (!_disposed) {
          setState(() {
            showSnackBar(context, '$e');
          });
        }
      });
    }

    if (feedManager.feeds == null) {
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
          return feedManager.refresh().catchError((e) {
            if (!_disposed) {
              setState(() {
                showSnackBar(context, '$e');
              });
            }
          });
        },
        child: body,
      ),
    );
  }

  void showSnackBar(BuildContext context, String text) {
    final ScaffoldState scaffoldState = Scaffold.of(context);
    scaffoldState.showSnackBar(new SnackBar(content: new Text(text)));
  }
}

Padding _pad() => const Padding(padding: const EdgeInsets.all(4.0));

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

    final List<Widget> topRow = <Widget>[
      new Expanded(
        child: new Text(
          '@${feed.user}' ?? '',
          style: authorStyle,
        ),
      ),
      _pad(),
    ];

    if (feed.urls.isNotEmpty) {
      topRow.add(new IconButton(
        icon: new Icon(Icons.open_in_new),
        onPressed: () => launch(feed.urls.first),
      ));
    }

    final List<Widget> bottomRow = <Widget>[
      new Expanded(
        child: new Text(
          feed.taggedDescription,
          style: dateStyle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      _pad(),
      new Text(
        feed.createdAtDescription ?? '',
        style: dateStyle,
      ),
    ];

    if (feed.favorite_count > 0) {
      bottomRow.add(
        new Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: new Icon(Icons.thumb_up, size: 16.0),
        ),
      );
      bottomRow.add(
        new Padding(
          padding: const EdgeInsets.only(left: 4.0),
          child: new Text(feed.favorite_count.toString()),
        ),
      );
    }

    return new Container(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: new Material(
        type: MaterialType.card,
        elevation: 1.0,
        child: new Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            new Padding(
              padding: const EdgeInsets.all(8.0),
              child: new Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  new Row(
                    children: <Widget>[
                      avatar,
                      _pad(),
                      new Expanded(
                        child: new Column(
                          children: <Widget>[
                            new Row(children: topRow),
                          ],
                          crossAxisAlignment: CrossAxisAlignment.start,
                        ),
                      ),
                    ],
                  ),
                  const Padding(padding: const EdgeInsets.all(4.0)),
                  new Text(feed.text, style: descStyle),
                  const Divider(),
                  new Row(children: bottomRow)
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Feed implements Comparable<Feed> {
  static Feed parse(dynamic json) {
    return new Feed(
      id_str: json['id_str'],
      user: json['user']['screen_name'],
      text: json['text'],
      created_at: _parseDates(json['created_at']),
      hashtags: json['entities']['hashtags']
          .map((h) => h['text'].toString())
          .toList()
          .cast<String>(),
      user_mentions: json['entities']['user_mentions']
          .map((h) => h['screen_name'].toString())
          .toList()
          .cast<String>(),
      urls:
          json['entities']['urls'].map((u) => u['url'].toString()).toList().cast<String>(),
      favorite_count: json['favorite_count'],
    );
  }

  // String twitterFormat="EEE MMM dd HH:mm:ss ZZZZZ yyyy"
  static DateFormat twitterDateFormat =
      new DateFormat('EEE MMM dd HH:mm:ss', 'en');

  static DateTime _parseDates(String text) {
    if (text.contains('+')) {
      text = text.substring(0, text.indexOf('+')).trim();
    }
    return twitterDateFormat.parse(text);
  }

  // These field names are deliberately kept the same as the twitter feed API.

  final String id_str; // ignore: non_constant_identifier_names
  final String user;
  final String text;
  final List<String> hashtags;
  final List<String> user_mentions; // ignore: non_constant_identifier_names
  final List<String> urls;
  final int favorite_count; // ignore: non_constant_identifier_names
  final DateTime created_at; // ignore: non_constant_identifier_names

  Feed({
    this.id_str, // ignore: non_constant_identifier_names
    this.user,
    this.text,
    this.created_at, // ignore: non_constant_identifier_names
    this.hashtags: const [],
    this.user_mentions: const [], // ignore: non_constant_identifier_names
    this.urls: const [],
    this.favorite_count: 0, // ignore: non_constant_identifier_names
  });

  String get avatarText => user.substring(0, 1).toUpperCase();

  @override
  bool operator ==(other) => other is Feed && id_str == other.id_str;

  @override
  int get hashCode => id_str.hashCode;

  static DateFormat dateFormat = new DateFormat('LLL d');
  static DateFormat timeFormat = new DateFormat.jm();

  String get createdAtDescription {
    return '${dateFormat.format(created_at)}';
  }

  String get taggedDescription {
    List<String> tags = hashtags.toList()..sort();
    return tags.map((h) => '#$h').join(' ').toLowerCase();
  }

  bool get hasUrl => urls.isNotEmpty;

  @override
  int compareTo(Feed other) {
    return other.created_at.compareTo(created_at);
  }
}

class FeedManager {
  final http.Client httpClient = createHttpClient();

  List<Feed> feeds;

  StreamController<List<Feed>> _feedController =
      new StreamController.broadcast();
  Future _loadFuture;
  String _bearerToken;

  FeedManager();

  Stream<List<Feed>> get onFeedsChanged => _feedController.stream;

  Future<List<Feed>> load() {
    if (_loadFuture != null) {
      return _loadFuture;
    }

    feeds ??= [];

    _loadFuture = _load();

    _loadFuture.then((feeds) {
      this.feeds = feeds;
      _feedController.add(feeds);
      return feeds;
    }).whenComplete(() {
      _loadFuture = null;
    });

    return _loadFuture;
  }

  Future<List<Feed>> _load() async {
    final Future<String> bundleData =
        rootBundle.loadString('assets/app.token.txt');
    final String token = (await bundleData)?.trim();

    http.Response response;

    response = await httpClient.post(
      'https://api.twitter.com/oauth2/token',
      body: 'grant_type=client_credentials',
      headers: {
        'Authorization': 'Basic $token',
        'Content-Type': 'application/x-www-form-urlencoded;charset=UTF-8',
      },
    );

    dynamic json;

    final String accessTokenData = response.body;
    json = convert.json.decode(accessTokenData);

    if (json is! Map) {
      throw 'Unexpected response from server.';
    }

    // either:
    //   {"token_type":"bearer","access_token":"..."}
    // or:
    //   {"errors":[{"code":99,"message":"Unable to verify your credentials","label":"authenticity_token_error"}]}
    Map m = json;

    if (m.containsKey('errors')) {
      throw _parseError(m['errors']);
    } else {
      _bearerToken = m['access_token'];

      return _query();
    }
  }

  Future<List<Feed>> _query() async {
    final String encodedQuery = Uri.encodeComponent(searchQuery);

    http.Response response;

    response = await httpClient.get(
      'https://api.twitter.com/1.1/search/tweets.json?q=$encodedQuery',
      headers: {
        'Authorization': 'Bearer $_bearerToken',
        'Content-Type': 'application/x-www-form-urlencoded;charset=UTF-8',
      },
    );

    dynamic result = convert.json.decode(response.body);

    int rateLimit = int.parse(response.headers['x-rate-limit-limit'] ?? '0');
    int limitRemaining =
        int.parse(response.headers['x-rate-limit-remaining'] ?? '0');
    int limitReset = int.parse(response.headers['x-rate-limit-reset'] ?? '0');
    int secondsLeft =
        (limitReset ?? 0) - (new DateTime.now().millisecondsSinceEpoch ~/ 1000);
    // Log the headers for the rate limiting.
    log('rate limit $limitRemaining / $rateLimit (reset in ${secondsLeft}s)',
        name: 'rateLimit');

    if ((result as Map).containsKey('errors')) {
      throw _parseError(result['errors']);
    }

    List<Feed> items = (result['statuses'] as List).map(Feed.parse).toList();
    items.sort();
    return items;
  }

  String _parseError(dynamic errors) {
    try {
      return errors[0]['message'];
    } catch (e) {
      return '$errors';
    }
  }

  Future<List<Feed>> refresh() {
    return _query().then((feeds) {
      this.feeds = feeds;
      _feedController.add(feeds);
      return feeds;
    });
  }
}
