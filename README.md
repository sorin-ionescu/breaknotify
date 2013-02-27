# Description

`breaknotify`, inspired by [Time Out][1] and [growlnotify][2], is a
notification daemon, which reminds the user to take breaks via Growl and
Notification Center also making an audible sound.

Though I have used Time Out for many years, I have found it frustrating because
it locks the screen breaking my concentration forcing me to click the Postpone
or Skip Break buttons to not lose my thought. Consequently, I tend to skip a lot
of brakes. Not only do I become tired but also irritated.

# Installation

1. Tap my [Homebrew][4] formulae.

        brew tap https://github.com/sorin-ionescu/homebrew-personal

2. Install `breaknotify`.

        brew install --HEAD breaknotify

# Configuration

1. Copy the sample configuration file to *~/Library/Preferences*.
2. Add or edit notifications.

## Notifications

An infinite number of notifications are supported. Notifications run in
sequence, from the first defined to the last.

```xml
<key>Notifications</key>
<array>
  <dict>
    <!-- The notification identifier, for example, Coffee Break. -->
    <key>Name</key>
    <string>Coffee Break</string>
    <!-- Whether the notification is enabled or disabled. -->
    <key>Enabled</key>
    <true/>
    <!-- Whether the notification is sticky or disappears after a few seconds. -->
    <key>Sticky</key>
    <false/>
    <!-- The interval in seconds, for example, 600.0 for 10 minutes. -->
    <key>Interval</key>
    <real>600.0</real>
    <!-- The notification title; make it short. -->
    <key>Title</key>
    <string>Hmm, Coffee!</string>
    <!-- The notification description is displayed bellow the title. -->
    <key>Description</key>
    <string>Drink the black elixir!</string>
    <!-- See /System/Library/Sounds for a list of sounds, for example, Blow. -->
    <key>Sound</key>
    <string>Blow</string>
  </dict>
</array>
```

## Silencers

Processes may silence notifications.

There is special support for [QuickTime Player][5], [MPlayerX][6], [VLC][7],
and [iTunes][8], which are enabled by default.

The aforementioned media players, except iTunes, silence notifications when any
media is playing; iTunes silences notifications only when it is playing videos.

```xml
<key>Silencers</key>
<array>
  <!-- A name of a process as it appears in the running processes list. -->
  <string></string>
</array>
```

# License

(The MIT License)

Copyright (c) 2013 Sorin Ionescu.

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
of the Software, and to permit persons to whom the Software is furnished to do
so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

## Icon

The clock was taken from [psdGraphics][9].

[1]: http://www.dejal.com/timeout
[2]: http://growl.info/extras.php#growlnotify
[3]: http://growl.info/downloads#devdownloads
[4]: http://mxcl.github.com/homebrew
[5]: http://www.apple.com/quicktime
[6]: http://mplayerx.org
[7]: http://www.videolan.org
[8]: http://www.apple.com/itunes
[9]: http://www.psdgraphics.com/psd/wall-clock-template
