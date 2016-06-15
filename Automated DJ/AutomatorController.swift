//
//  AutomatorController.swift
//  Automated DJ
//
//  Created by Zachary Whitten on 6/5/16.
//  Copyright © 2016 16^2. All rights reserved.
//

import Foundation
import Cocoa

class AutomatorController: NSObject {
    @IBOutlet weak var MasterScheduleObject: MasterSchedule!
    @IBOutlet weak var PreferencesObject: Preferences!
    @IBOutlet weak var GlobalAnnouncementsObject: GloablAnnouncements!

    func spawnMasterTimer(){
        NSTimer.scheduledTimerWithTimeInterval(60, target: self, selector: #selector(masterTimerFunction), userInfo: nil, repeats: true)
    }
    
    func masterTimerFunction(){
        let applescriptBridge = ApplescriptBridge()
        //Create a date object 3 minutes in the future (NOTE: Because of how the timer is configured - to fire every minute - this we will give us a max of three minutes before a show and a minimum of two)
        let futureTime = NSDate.init().dateByAddingTimeInterval(180)
        //Create date formatter, which represents a date as a weekday and the hour and minute. And two more for minute and second respectivally.
        let dateFormatterShowTime = NSDateFormatter()
        dateFormatterShowTime.dateFormat = "EEEE 'at' HH:mm"
        let minuteFormatter = NSDateFormatter()
        minuteFormatter.dateFormat = "mm"
        let secondFormatter = NSDateFormatter()
        secondFormatter.dateFormat = "ss"
        
        //Iterate though all shows and if the start time of a show matches the future time... (Do things)
        for aShow in MasterScheduleObject.dataArray {
            if dateFormatterShowTime.stringFromDate(aShow.startDate!) == dateFormatterShowTime.stringFromDate(futureTime){
                //Determine the name of our generated playlist. This is done to prevent name overlap. We also delete any automated DJ playlist which is not currently playing so that we do not have duplicates of the same playlist.
                var generatedPlaylistName = "Automated DJ"
                //get currently playing playlist
                let currentPlaylist = applescriptBridge.getCurrentPlaylist()
                if currentPlaylist != "Automated DJ" && currentPlaylist != "Automated DJ2" {
                    applescriptBridge.deletePlaylistWithName("Automated DJ")
                    applescriptBridge.deletePlaylistWithName("Automated DJ2")
                }
                else if currentPlaylist == "Automated DJ2" {
                    applescriptBridge.deletePlaylistWithName("Automated DJ")
                }
                else if currentPlaylist == "Automated DJ" {
                    applescriptBridge.deletePlaylistWithName("Automated DJ2")
                    generatedPlaylistName = "Automated DJ2"
                }
                //Get the number of seconds into the hour that the show starts and of the current time. Get the difference of those two numbers and we have the number of seconds until the show begins, which we use as our delay time. If the show starts in the next hour relative to the hour of the current time, then the resulting difference is a negative number. Adding 60 to that negative number gets us the positive number of seconds until the show begins.
                let showStartTimeSeconds = (Int(minuteFormatter.stringFromDate(aShow.startDate!))! * 60)
                let currentTimeSeconds = (Int(minuteFormatter.stringFromDate(NSDate.init()))! * 60) + (Int(secondFormatter.stringFromDate(NSDate.init())))!
                let delay = showStartTimeSeconds - currentTimeSeconds
                if delay < 0 {delay + 60}
                //If the show is not automated then only the global announcements window needs to be spawned
                if aShow.automator == nil {
                    let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(Double(delay + PreferencesObject.globalAnnouncementsDelay) * Double(NSEC_PER_SEC)))
                    dispatch_after(delayTime, dispatch_get_main_queue()) {
                        self.GlobalAnnouncementsObject.spawnImmutableGlobalAnnouncements()
                    }
                }
                //If the show is automated, a playlist must be generated and played
                else{
                    let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(Double(delay) * Double(NSEC_PER_SEC)))
                    dispatch_after(delayTime, dispatch_get_main_queue()) {
                       self.playGeneratedPlaylist(generatedPlaylistName)
                    }
                    generatePlaylist(generatedPlaylistName, anAutomator: aShow.automator!)
                }
                break;
            }
        }
    }
    
    func generatePlaylist(playlistName: String, anAutomator: Automator){
        let applescriptBridge = ApplescriptBridge()
        let generatedPlaylist: NSMutableArray = NSMutableArray()
        //Get tiered playlists
        let tier1 = applescriptBridge.getSongsInPlaylist("Tier 1")
        let tier2 = applescriptBridge.getSongsInPlaylist("Tier 2")
        let tier3 = applescriptBridge.getSongsInPlaylist("Tier 3")
        //Apply rules to tiered playlists if rules exist
        if anAutomator.rules != nil {
            tier1.filterUsingPredicate(anAutomator.rules!)
            tier2.filterUsingPredicate(anAutomator.rules!)
            tier3.filterUsingPredicate(anAutomator.rules!)
        }
        //get seed playlist if it exists and add seed playlist to generated playlist
        //TODO test if this handles a non existant but non null playlist
        if anAutomator.seedPlayist != nil{
            generatedPlaylist.addObjectsFromArray(applescriptBridge.getSongsInPlaylist(anAutomator.seedPlayist) as [AnyObject])
            //Remove excess if seed playlist is longer than playlist length
            //While actual time is greater than expected time + tolerance
            while Playlist.getNewPlaylistDuration(generatedPlaylist as Array as! [Song]) > (anAutomator.totalTime + Double(PreferencesObject.tollerence)) {
                generatedPlaylist.removeLastObject()
            }
        }
        
        
        //algorithm 
        
    }
    
    func playGeneratedPlaylist(playlistName: String){
        let applescriptBridge = ApplescriptBridge()
        //Disable shuffle && looping
        applescriptBridge.disableShuffle()
        applescriptBridge.disableRepeat()
        //delay until current song concludes
        //TODO test how good the delay is. Subtracting half a second from the dealy is a holdover from the 1.0 release. Make sure its still necessary
        var rawDelayTime = applescriptBridge.timeLeftInCurrentSong()
        var delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64( (rawDelayTime - 0.5) * Double(NSEC_PER_SEC)))
        //If iTunes is not playing, then set the delay to 0. (This needs to be done because if a song is paused midway, then timeLeftInCurrentSong will return a greater than zero value, because thats how much time is left in the song! THe only issue is that the song isnt playing. So unchecked, we would wait in silence)
        if applescriptBridge.isiTunesPlaying() == false {
            delayTime = 0
            rawDelayTime = 0
        }
        dispatch_after(delayTime, dispatch_get_main_queue()) {
            applescriptBridge.playPlaylist(playlistName)
        }
        //trim excess fat from generated playlist if possible.
        //if the raw delay time is greater than the last song of the playlist, then subtract the length of that song from the raw delay time and remove that song from the playlist. We then check again to see if the newly updated raw delay time is greater than the (new) last song of the playlist. If so, repeat until no longer the case
        while rawDelayTime > applescriptBridge.getLastSongInPlaylist(playlistName).duration {
            rawDelayTime = rawDelayTime - applescriptBridge.getLastSongInPlaylist(playlistName).duration
            applescriptBridge.removeLastSongInPlaylist(playlistName)
        }
    }
    
}