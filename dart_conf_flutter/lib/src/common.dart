// Copyright (c) 2017, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/material.dart';

final ThemeData _theme = new ThemeData(primarySwatch: Colors.blue);

ThemeData get appTheme => _theme;

Widget pad8([Widget child]) {
  return new Padding(padding: const EdgeInsets.all(8.0), child: child);
}

String addParagraphs(String str) {
  return str?.replaceAll('<p>', '\n')?.replaceAll('  ', '\n\n');
}
