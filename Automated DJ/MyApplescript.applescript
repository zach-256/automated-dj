script MyApplescript
    property parent : class "NSObject"
    
    on iTunesPause()
        tell application "iTunes"
            pause
        end tell
    end iTunesPause
    
    on getPlaylists()
        tell application "iTunes"
            get properties of playlists
        end tell
    end getPlaylists
    
    on getPlaylist_(aPlaylist as string)
        tell application "iTunes"
            get properties of aPlaylist
        end tell
    end getPlaylist_
    
    on getSongsInPlaylist_(aPlaylist as string)
        tell application "iTunes"
            set my_playlist to get playlist aPlaylist
            get properties of tracks of my_playlist
        end tell
    end getSongsInPlaylist_
    
    on getLastSongInPlaylist_(aPlaylist as string)
        tell application "iTunes"
            set trackNumber to count of tracks of playlist aPlaylist
            return properties of track trackNumber of playlist aPlaylist
        end tell
    end getLastSongInPlaylist_
    
    on removeLastSongInPlaylist_(aPlaylist as string)
        tell application "iTunes"
            set trackNumber to count of tracks of playlist aPlaylist
            delete track trackNumber of playlist aPlaylist
        end tell
    end removeLastSongInPlaylist_
    
    on createPlaylistWithName_(aName as string)
        tell application "iTunes"
            make user playlist with properties {name:aName}
        end tell
    end createPlaylistWithName_
    
    on getCurrentPlaylist()
        tell application "iTunes"
            get name of current playlist
        end tell
    end getCurrentPlaylist
    
    on deletePlaylistWithName_(aName as string)
        tell application "iTunes"
            try
                delete playlist aName
            end try
        end tell
    end deletePlaylistWithName_
    
    on disableShuffle()
        tell application "iTunes"
            set shuffle enabled to false
        end tell
    end disableShuffle
    
    on disableRepeat()
        tell application "iTunes"
            set song repeat to off
        end tell
    end disableRepeat
    
    on timeLeftInCurrentSong()
        tell application "iTunes"
            set totalTime to duration of current track
            set currentTime to player position
            return totalTime - currentTime
        end tell
    end timeLeftInCurrentSong
    
    on playPlaylist_(aPlaylist as string)
        tell application "iTunes"
            try
                play playlist aPlaylist
            end try
        end tell
    end playPlaylist_
    
    on getiTunesPlayerState()
        tell application "iTunes"
            return player state
        end tell
    end getiTunesPlayerState
    
end script