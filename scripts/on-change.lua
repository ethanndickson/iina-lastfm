function track_load()
    os.execute("/usr/bin/env bash ~/.config/mpv/lastfmscrobbler/scrobble.sh")
end

mp.register_event("file-loaded", track_load)
