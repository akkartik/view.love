# A read-only viewer for plain text.

[![0 dependencies!](https://0dependencies.dev/0dependencies.svg)](https://0dependencies.dev)

Not very useful by itself, but it's a fork of [lines.love](http://akkartik.name/lines.html)
that you can take in other directions, while easily sharing patches between
forks.

Designed above all to be easy to modify and give you early warning if your
modifications break something.

## Getting started

Install [LÖVE](https://love2d.org). It's just a 5MB download, open-source and
extremely well-behaved.

To run from the terminal, [pass this directory to LÖVE](https://love2d.org/wiki/Getting_Started#Running_Games),
optionally with a file path to edit.

Alternatively, turn it into a .love file you can double-click on:
```
$ zip -r /tmp/view.love *.lua
```

By default, it reads/writes the file `lines.txt` in
[a directory relative to this app](https://love2d.org/wiki/love.filesystem.getSourceBaseDirectory).

To open a different file, drop it on the app window.

## Keyboard shortcuts

While editing text:
* `ctrl+f` to find patterns within a file
* `ctrl+c` to copy, `ctrl+x` to cut, `ctrl+v` to paste
* `ctrl+z` to undo, `ctrl+y` to redo
* `ctrl+=` to zoom in, `ctrl+-` to zoom out, `ctrl+0` to reset zoom
* `alt+right`/`alt+left` to jump to the next/previous word, respectively
* mouse drag or `shift` + movement to select text, `ctrl+a` to select all
* `ctrl+e` to modify the sources

Exclusively tested so far with a US keyboard layout. If
you use a different layout, please let me know if things worked, or if you
found anything amiss: http://akkartik.name/contact

## Known issues

* No support yet for Unicode graphemes spanning multiple codepoints.

* No support yet for right-to-left languages.

* Can't scroll while selecting text with mouse.

* No scrollbars yet. That stuff is hard.

## Mirrors and Forks

This repo is a fork of [lines.love](http://akkartik.name/lines.html), an
editor for plain text where you can also seamlessly insert line drawings.
Its immediate upstream is [text.love](https://git.sr.ht/~akkartik/text.love),
a version without support for line drawings. Updates to it can be downloaded
from the following mirrors:

* https://git.sr.ht/~akkartik/view.love
* https://repo.or.cz/view.love.git
* https://tildegit.org/akkartik/view.love
* https://git.tilde.institute/akkartik/view.love
* https://git.merveilles.town/akkartik/view.love
* https://github.com/akkartik/view.love
* https://codeberg.org/akkartik/view.love
* https://notabug.org/akkartik/view.love
* https://pagure.io/view.love
* https://nest.pijul.com/akkartik/view.love (using the Pijul version control system)

Further forks are encouraged. If you show me your fork, I'll link to it here.

## Feedback

[Most appreciated.](http://akkartik.name/contact) Messages, PRs, patches,
forks, it's all good.
