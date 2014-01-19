TMPTaskCompletionManager [![Build Status](https://travis-ci.org/n-miyo/TMPTaskCompletionManager.png?branch=master)](https://travis-ci.org/n-miyo/TMPTaskCompletionManager)
====================


DESCRIPTION
--------------------

The `TMPTaskCompletionManager` class provides functions for supporting
task completion, especially for multiple background tasks.

In task completion, an application must manage UIBackgroundTaskIdentifier
value for invoking endBackgroundTask correctly.  It's a little bit
bother task if you have to control multiple background tasks.

This class supports for tracking UIBackgroundTaskIdentifier.


PLATFORM
--------------------

iOS 6.1 and above.  You have to enable ARC.


PREPARATION
--------------------

Set up `Podfile` for using `TMPTaskCompletionManager` such as:

    pod 'TMPTaskCompletionManager'

or just copy TMPTaskCompletionManager.h and TMPTaskCompletionManager.m
in Lib directory to your project.


USAGE
--------------------

See TMPTaskCompletionManager.h as API documents or check
`TMPTaskCompletionManager` for sample.


AUTHOR
--------------------

MIYOKAWA, Nobuyoshi

* E-Mail: n-miyo@tempus.org
* Twitter: nmiyo
* Blog: http://blogger.tempus.org/


COPYRIGHT
--------------------

MIT LICENSE

Copyright (c) 2013-2014 MIYOKAWA, Nobuyoshi (http://www.tempus.org/)

Permission is hereby granted, free of charge, to any person obtaining a
copy of this software and associated documentation files (the "Software"),
to deal in the Software without restriction, including without limitation
the rights to use, copy, modify, merge, publish, distribute, sublicense,
and/or sell copies of the Software, and to permit persons to whom the
Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
DEALINGS IN THE SOFTWARE.
