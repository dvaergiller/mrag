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

## Gotchas

### Writing to a log with the name of a preexisting folder results in 500

```bash
$ curl -iX POST localhost:8083/a/b -d "test"
HTTP/1.1 200 OK
Transfer-Encoding: chunked
Date: Mon, 01 May 2017 13:43:38 GMT
Server: Warp/3.2.9

$ curl -iX POST localhost:8083/a -d "test"
HTTP/1.0 500 Internal Server Error
Date: Mon, 01 May 2017 13:43:44 GMT
Server: Warp/3.2.9
Content-Type: text/plain; charset=utf-8

Something went wrong
```

### Creating a folder with the name of a preexisting log results in 500

```bash
$ curl -iX POST localhost:8083/a -d "test"
HTTP/1.1 200 OK
Transfer-Encoding: chunked
Date: Mon, 01 May 2017 13:44:31 GMT
Server: Warp/3.2.9

$ curl -iX POST localhost:8083/a/b -d "test"
HTTP/1.0 500 Internal Server Error
Date: Mon, 01 May 2017 13:44:36 GMT
Server: Warp/3.2.9
Content-Type: text/plain; charset=utf-8

Something went wrong
```

### Performing GET on a folder results in 404

```bash
$ curl -iX POST localhost:8083/a/b -d "test"
HTTP/1.1 200 OK
Transfer-Encoding: chunked
Date: Mon, 01 May 2017 13:45:12 GMT
Server: Warp/3.2.9

$ curl -iX GET localhost:8083/a
HTTP/1.1 404 Not Found
Transfer-Encoding: chunked
Date: Mon, 01 May 2017 13:45:20 GMT
Server: Warp/3.2.9

Not Found
```