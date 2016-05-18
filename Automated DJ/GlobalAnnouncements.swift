//
//  GlobalAnnouncements.swift
//  Automated DJ
//
//  Created by Zachary Whitten on 5/17/16.
//  Copyright © 2016 16^2. All rights reserved.
//

import Foundation
import Cocoa

class GloablAnnouncements: NSObject, NSTableViewDataSource, NSTableViewDelegate {
    @IBOutlet weak var AppDelegateObject: AppDelegate!
    @IBOutlet weak var globalAnnouncementsWindow: NSWindow!
    @IBOutlet weak var addGlobalAnnouncementWindow: NSWindow!
    @IBOutlet var addGlobalAnnouncementText: NSTextView!
    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet var settingTextView: NSTextView!
    
    var dataArray = [String]()
    
    @IBAction func spawnNewAnnouncementWindow(sender: AnyObject) {
        addGlobalAnnouncementWindow.title = "New Announcement"
        addGlobalAnnouncementWindow.center()
        addGlobalAnnouncementWindow.makeKeyAndOrderFront(self)
        NSApp.runModalForWindow(addGlobalAnnouncementWindow)
    }
    
    @IBAction func addAnnouncement(sender: AnyObject) {
        dataArray.append(addGlobalAnnouncementText.string!)
        NSKeyedArchiver.archiveRootObject(dataArray, toFile: AppDelegateObject.storedAnnouncementsFilepath)
        tableView.reloadData()
        cancelNewAnnouncement(self)
    }
    
    @IBAction func cancelNewAnnouncement(sender: AnyObject) {
        addGlobalAnnouncementText.string = ""
        NSApp.stopModal()
        addGlobalAnnouncementWindow.orderOut(self)
    }
    
    func tableView(tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        //set the TextView (Which as the same width as the GlobalAnnouncements tableView cell) to the string at the given row in the data array. Then calculate how large the cell needs to be and retrun that value.
        settingTextView.string = dataArray[row]
        return (17.0 * CGFloat(numOfLinesIn(settingTextView)))
    }
    
    func numOfLinesIn(aTextView: NSTextView) -> Int {
        let layoutManager = aTextView.layoutManager
        var numberOfLines = 0
        var index = 0
        var lineRange = NSRange()
        let numberOfGlyphs = layoutManager!.numberOfGlyphs
        
        while index < numberOfGlyphs {
            layoutManager!.lineFragmentRectForGlyphAtIndex(index, effectiveRange: &lineRange)
            index = NSMaxRange(lineRange);
            numberOfLines += 1
        }
        print(numberOfLines)
        if numberOfLines == 0 {return 1}
        return numberOfLines
    }
    
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        return dataArray.count
    }
    
    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
        //Get the column identifer, the show for the current row, and create an cellView variable
        let anAnnouncement = dataArray[row]
        let cellView = (tableView.makeViewWithIdentifier("announcementsCell", owner: nil) as? NSTableCellView)!
        
        cellView.textField?.stringValue = anAnnouncement
        
        // return the populated NSTableCellView
        return cellView
        
    }
    
    
}