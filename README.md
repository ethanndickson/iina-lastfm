# iina-lastfm
[mpv](https://github.com/mpv-player/mpv) script to scrobble songs played through [iina](https://github.com/iina/iina) to last.fm, since nobody else has made one.

No dependencies! Runs on macOS Big Sur with just iina installed. 

Last tested on iina 1.2.0.

If you want to run this on mpv for Windows or Linux make sure you have netcat and perl on your PATH.

# Installing 

1. In iina advanced preferences, enable advanced mode, and set the config directory to `~/.config/mpv/`

2. In iina advanced preferences, enable:

    | Name      | Value |
    | ----------- | ----------- |
    | load-scripts| yes       |
    | input-ipc-server   | /tmp/mpv-socket       |

3. Copy the `lastfmscrobbler` folder and the `scripts` folder into `~/.config/mpv/`

4. Open `lastfmscrobbler/scrobble.pl` and modify the following lines with your last.fm login:
```
$USERNAME = "myUsername"
$PASSWORD = "myPassword"
```