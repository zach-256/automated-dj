//
//  GlobalAnnouncementsWindow.swift
//  Automated DJ
//
//  Created by Zachary Whitten on 5/19/16.
//  Copyright © 2016 16^2. All rights reserved.
//

import Foundation
import Cocoa

class GlobalAnnoucementsWindow: NSWindow {
    @IBOutlet weak var GlobalAnnouncementsObject: GloablAnnouncements!
    @IBOutlet weak var AppDelegateObject: AppDelegate!

    override func keyDown(anEvent: NSEvent) {
        //get the key modifier flags, and use the bitwise and function to remove the machine specific bits. Leaving you with the unadulatrated modiferFlag
        let trueRawModiferFlag = anEvent.modifierFlags.rawValue & NSEventModifierFlags.DeviceIndependentModifierFlagsMask.rawValue
            //If the key ModiferFlag equates to the command key being pressed
            if (trueRawModiferFlag == NSEventModifierFlags.CommandKeyMask.rawValue) {
                //If the E key (which has a keyCode of 14) is pressed along with the command key, call the edit function
                if anEvent.keyCode == 14  && GlobalAnnouncementsObject.isMutable == true{
                    GlobalAnnouncementsObject.editAnnouncement(self)
                }
                //If the , key (which has a keyCode of 43) is pressed along with the command key, call the showPreferences function
                if anEvent.keyCode == 43 {
                    AppDelegateObject.showPreferences()
                }
                //if the q key (key code 12) is pressed along with the command key call the terminate function
                if anEvent.keyCode == 12 {
                    AppDelegateObject.terminate()
                }
                //Else just do what would have been expected
                else{
                    super.keyDown(anEvent)
                }
            }
            //If the ket ModiferFlag equates to the command and shift key being pressed
            else if (trueRawModiferFlag == (NSEventModifierFlags.CommandKeyMask.rawValue + NSEventModifierFlags.ShiftKeyMask.rawValue)) {
                //if the s key (key code 1) is pressed aling with the command and shift key, call the showSchedule function
                if anEvent.keyCode == 1{
                    AppDelegateObject.showSchedule()
                }
                //if the a key (key code 0) is pressed aling with the command and shift key, call the showAnnouncements function
                if anEvent.keyCode == 0{
                    AppDelegateObject.showAnnouncements()
                }
                //if the e key (key code 14) is pressed aling with the command and shift key, call the editAnnouncements function
                if anEvent.keyCode == 14 {
                    AppDelegateObject.editAnnouncements()
                }
                    //Else just do what would have been expected
                else{
                    super.keyDown(anEvent)
                }
            }
            //Else if the delete key (key code 51) is pressed call the delete function
            else if(anEvent.keyCode == 51 && GlobalAnnouncementsObject.isMutable == true){
                GlobalAnnouncementsObject.deleteAnnouncements(self)
            }
            //Else just do what would have been expected
            else{
                super.keyDown(anEvent)
            }
        }
    }