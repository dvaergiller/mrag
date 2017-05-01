# Simple logging utility over HTTP

Each call appends the provided data to a file as-is. There are no
checks on the actual content itself.

This is intended for my own personal use, and is intentionally kept
simple and "stupid".

This is currently NOT TESTED on Windows platforms. If you try this out
in Windows, please let met know.

## To build project:
  1. Make sure haskell and cabal are installed
  2. `# cabal sandbot init` (optional)
  3. `# cabal install` (to install dependencies, will take a while)
  4. `# cabal build`

  The binary should then be found at `dist/build/mrag/mrag`

## To start server:
  `# mrag <PORT> <DOCROOT>`

## To write to log:
  `# curl -X POST <HOSTNAME>:<PORT>/path/to/log`

  Log or path does not need to exist beforehand. Line terminator is
  atomatically added on each call. No need to add that yourself.

## To read log:
  `# curl -X GET <HOSTNAME>:<PORT>/path/to/log`
