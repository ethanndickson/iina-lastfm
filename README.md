# iina-lastfm
[mpv](https://github.com/mpv-player/mpv) script to scrobble songs played through [iina](https://github.com/iina/iina) to last.fm, since nobody else has made one.

No dependencies! Runs on macOS Big Sur(+) with just iina installed.

Last tested on iina 1.3.5 & macOS Ventura 13.5.

You could probably get this working for mpv on other operating systems.

# Installing 

1. In iina advanced preferences, enable advanced mode, and set the config directory to `~/.config/mpv/`

2. In iina advanced preferences, enable:

    | Name      | Value |
    | ----------- | ----------- |
    | load-scripts| yes       |
    | input-ipc-server   | /tmp/mpv-socket       |

3. Copy the `lastfmscrobbler` folder and the `scripts` folder into `~/.config/mpv/`

4. Open `lastfmscrobbler/scrobble.sh` and modify the `USERNAME` variable:
```
USERNAME='lastfmUsername'
```

5. In a terminal, write your last.fm password to the `login` keychain, under the `com.iina.lastfm` service:
```
security add-generic-password -a "lastfmUsername" -s "com.iina.lastfm" -w "mypassword"
```


# Debugging
With iina open and playing a track, run `scrobble.sh` directly and check the error.

 `/usr/bin/env bash ~/.config/mpv/lastfmscrobbler/scrobble.sh`

The script won't work unless the track you're playing has both of these metadata tags.

`'TITLE'|'Title'|'title'`

`'ARTIST'|'Artist'|'artist'` 

You can see the raw metadata of the track when iina is running with

```echo '{ "command": ["get_property", "metadata"] }' | nc -U  /tmp/mpv-socket```

If the program is scrobbling when you run `scrobble.sh` manually but not automatically, check iina.log for lua errors.
