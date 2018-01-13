# DartConf

[![Build Status](https://travis-ci.org/dart-lang/conference_app.svg?branch=master)](https://travis-ci.org/dart-lang/conference_app)

A conference app for DartConf 2018.

## App Overview

This is a mobile app for DartConf 2018. The overall design is roughly modelled
after the 2017 Google I/O app. It's organized into 4 separate pages:

![DartConf 2018 Atom screenshot](docs/flutter_01.png)

### Schedule page

This is a page for the conference schedule (and the main landing page). It shows
two tabs; one for the first day of the conference and one for the 2nd (Jan 23rd and
Jan 24th). Each tab shows a chronological list of the conference sessions for that
day. Each session shows as a material card. Clicking on a session will open the
session in a separate page, and show more detailed information including the full
session description. We use a hero animation when transitioning from the session
card to the session page.

The data for the sessions, including the full list of sessions, the title, presenters,
date and time, duration, description, and presenter image, is backed by firebase.
Editing any of this info in the firebase admin page will do a live update of all
clients automatically.

### Info page

This is a page for general conference information. It's broken into a handful of
categories, and each category has a short amount of descriptive text.

The data is backed by firebase; editing the category list or info item title
or text in the firebase admin UI will update clients automatically.

### Map page

This is a static image of the conference location.

### Feeds page

This is a live Twitter feed of any tweets matching the search term
`#dartconf OR #flutterio OR #angulardart`. Selecting a tweet will open the corresponding
item directly at twitter.com. A pull-down gesture will refresh the tweet data.

## Build the app in release mode (Android)

To build the app in release mode for Android, you will need to provide two files:

 * `android/app/signing/release.keystore`
 * `android/app/signing/release.properties`

The first file is a standard Android keystore file that is used to sign the application,
while the properties file contains the informations necessary to access the keystore and
sign the builds.

If you don't provide these two files, the app building will fail when you try to build or
run a release version. The debug signing configuration is provided in the Git repo and as
such no configuration is necessary to run Android debug builds.

### Create a signing configuration for release

To generate a keystore, you need the JDK's `keytool` on your path, then run from the
project root:

```sh
$ keytool -genkey -v -keystore android/app/signing/release.keystore \
    -storepass "{✏️ YOUR STORE PASSWORD}" \
    -alias "{✏️ YOUR SIGNING KEY NAME, e.g., 'dartconf'}" \
    -keypass "{✏️ YOUR SIGNING KEY PASSWORD}" \
    -keyalg RSA -validity 14000
```

This will generate the signing keystore in `android/app/signing/release.keystore`.
Next, you will need a properties file containing the signing configuration. You can
create one by running from the project root:

```sh
$ tee android/app/signing/release.properties <<EOF
storeFile=release.keystore
storePassword={✏️ YOUR STORE PASSWORD}
keyAlias={✏️ YOUR SIGNING KEY NAME, e.g., 'dartconf'}
keyPassword={✏️ YOUR SIGNING KEY PASSWORD}
EOF
```

Remember to fill in the placeholders in both snippets with the same values!
