function track_load()
    -- local data = mp.get_property_native("metadata") # This is nil for some reason, but not in mpv...
    os.execute("perl ~/.config/mpv/lastfmscrobbler/scrobble.pl")
end

mp.register_event("file-loaded", track_load)
