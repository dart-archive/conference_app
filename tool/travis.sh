#!/bin/bash

# Copyright (c) 2018, the Dart project authors.  Please see the AUTHORS file
# for details. All rights reserved. Use of this source code is governed by a
# BSD-style license that can be found in the LICENSE file.

# Fast fail the script on failures.
set -e

# Get flutter.
(cd ..; git clone https://github.com/flutter/flutter.git)
export PATH="../flutter/bin:$PATH"
flutter --version

# Provision pub packages.
flutter packages get

# Ensure the code analyzes cleanly.
touch assets/app.token.txt
flutter analyze
