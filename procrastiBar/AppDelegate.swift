//
//  AppDelegate.swift
//  procastiBar
//
//  Created by Pascal Blunk on 07.09.15.
//  Copyright (c) 2015 Codingcave.de. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!

    //MARK: - StatusBarItem
    let statusItem: NSStatusItem
    let popover: NSPopover
    let picturePopover: NSPopover
    var popoverMonitor: AnyObject?
    
    override init() {
        let _ = NetworkHandler.sharedInstance
        popover = NSPopover()
        popover.contentViewController = ContentViewController()
        statusItem = NSStatusBar.system().statusItem(withLength: 24)
        popover.behavior = NSPopoverBehavior.semitransient
        
        picturePopover = NSPopover()
        picturePopover.contentViewController = PictureViewController()
        super.init()
        setupStatusButton()
        NotificationCenter.default.addObserver(self, selector: #selector(AppDelegate.handlePictureRcvdNote(_:)) , name: NSNotification.Name(rawValue: NetworkHandler.kImageRcvd), object: nil)
    }
    
    func setupStatusButton() {
        if let statusButton = statusItem.button {
            statusButton.image = NSImage(named: "Status")
            statusButton.alternateImage = NSImage(named: "StatusHighlighted")
            
            //
            // WORKAROUND
            //
            // DummyControl interferes mouseDown events to keep statusButton highlighted while popover is open.
            //
            let dummyControl = DummyControl()
            dummyControl.frame = statusButton.bounds
            statusButton.addSubview(dummyControl)
            statusButton.superview!.subviews = [statusButton, dummyControl]
            dummyControl.action = #selector(AppDelegate.onPress(_:))
            dummyControl.target = self
        }
    }
    
    func onPress(_ sender: AnyObject) {
        if(picturePopover.isShown){
           closePopover()
        }
        if popover.isShown == false {
            openPopover()
        }
        else {
            closePopover()
        }
    }
    
    func openPopover() {

        if let statusButton = statusItem.button {
            statusButton.highlight(true)
            //statusButton.window?.collectionBehavior = NSWindowCollectionBehavior.Transient | NSWindowCollectionBehavior.IgnoresCycle  | NSWindowCollectionBehavior.FullScreenAuxiliary | NSWindowCollectionBehavior.CanJoinAllSpaces
            
            print("iwndow \(statusButton.window)")
            popover.show(relativeTo: NSZeroRect, of: statusButton, preferredEdge: NSRectEdge.minY)
            popoverMonitor = NSEvent.addGlobalMonitorForEvents(matching: .leftMouseDown, handler: { (event: NSEvent) -> Void in
                self.closePopover()
            }) as AnyObject?
        }
    }
    
    func closePopover() {
        if(picturePopover.isShown){
            picturePopover.close()
        }
        if(popover.isShown){
            popover.close()
        }
        if let statusButton = statusItem.button {
            statusButton.highlight(false)
        }
        if let monitor : AnyObject = popoverMonitor {
            NSEvent.removeMonitor(monitor)
            popoverMonitor = nil
        }
    }
    
    //MARK: - showing picture
    
    func handlePictureRcvdNote(_ note:Notification){
        if let uInfo = note.userInfo{
            if let image = uInfo["image"] as? NSImage{
                self.closePopover()
                (self.picturePopover.contentViewController as? PictureViewController)?.img = image
                self.openPicturePopover()
            }
        }
        
    }
    
    func openPicturePopover() {
        if let statusButton = statusItem.button {
            statusButton.highlight(true)
            picturePopover.show(relativeTo: NSZeroRect, of: statusButton, preferredEdge: NSRectEdge.minY)
            popoverMonitor = NSEvent.addGlobalMonitorForEvents(matching: .leftMouseDown, handler: { (event: NSEvent) -> Void in
                self.closePopover()
            }) as AnyObject?
        }
    }
    //MARK: - AppDelegate
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        
        
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }


}

