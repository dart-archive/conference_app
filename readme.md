# DartConf

[![Build Status](https://travis-ci.org/dart-lang/conference_app.svg?branch=master)](https://travis-ci.org/dart-lang/conference_app)

A conference app for DartConf 2018.

## App Overview

This is a mobile app for DartConf 2018. The overall design is roughly modelled
after the 2017 Google I/O app. It's organized into 4 separate pages:

![DartConf 2018 Atom screenshot](https://raw.githubusercontent.com/dart-lang/conference_app/master/dart_conf_flutter/docs/flutter_01.png)

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

### Feeds page

This is a live Twitter feed of any tweets matching the search term
`#dartconf OR #flutterio OR #angulardart`. Selecting a tweet will open the cooresponding
item directly at twitter.io. A pull-down gesture will refresh the tweet data.

### Map page

This is a static image of the conference location.

### Info page

This is a page for general conference information. It's broken into a handful of
categories, and each category has a short amount of descriptive text.

The data is backed by firebase; editing the category list or info item title
or text in the firebase admin UI will update clients automatically.
