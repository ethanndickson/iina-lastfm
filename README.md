# iina-lastfm
[mpv](https://github.com/mpv-player/mpv) script to scrobble songs played through [iina](https://github.com/iina/iina) to last.fm, since nobody else has made one.

No dependencies! Runs on macOS Big Sur with just iina installed - thanks core Perl!

Last tested on iina 1.3.0.

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
$USERNAME = 'myUsername'
$PASSWORD = 'myPassword'
```


# Debugging
With iina open and paused playing a track, run `scrobble.pl` directly and check the error.

 `perl ~/.config/mpv/lastfmscrobbler/scrobble.pl`

The script won't work unless the track you're playing has both of these metadata tags.

`'TITLE'|'Title'|'title'`

`'ARTIST'|'Artist'|'artist'` 

You can see the raw metadata of the track when iina is running with

```echo '{ "command": ["get_property", "metadata"] }' | nc -U  /tmp/mpv-socket```

If the program is scrobbling when you run `scrobble.pl` manually but not automatically, check iina.log for lua errors.
