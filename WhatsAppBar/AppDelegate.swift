//
//  AppDelegate.swift
//  WhatsAppBar
//
//  Created by Aldy on 20/05/2018.
//  Copyright © 2018 Aldy. All rights reserved.
//

import Cocoa
import ServiceManagement

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    let statusItem = NSStatusBar.system.statusItem(withLength:NSStatusItem.squareLength)
    let popover = NSPopover()
    
    var eventMonitor: EventMonitor?
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        
        if let button = statusItem.button {
            button.image = NSImage(named:NSImage.Name("StatusBarButtonImage"))
            button.action = #selector(togglePopover(_:))
        }
        
        popover.contentViewController = MainViewController.freshController()
        
        eventMonitor = EventMonitor(mask: [.leftMouseDown, .rightMouseDown]) { [weak self] event in
            if let strongSelf = self, strongSelf.popover.isShown {
                strongSelf.closePopover(sender: event)
            }
        }
        
        let launcherAppId = "com.aldychris.whatsappbar.Launcher"
        let runningApps = NSWorkspace.shared.runningApplications
        let isRunning = !runningApps.filter { $0.bundleIdentifier == launcherAppId }.isEmpty
        
        if UserDefaults.didEnableStartOnLogin == 1 {
            SMLoginItemSetEnabled(launcherAppId as CFString, true)
        } else {
            SMLoginItemSetEnabled(launcherAppId as CFString, false)
        }
        
        if isRunning {
            DistributedNotificationCenter.default().post(name: .killLauncher,
                                                         object: Bundle.main.bundleIdentifier!)
        }
        
//        UserDefaults.clearUserData()
    }

    @objc func togglePopover(_ sender: Any?) {
        if popover.isShown {
            closePopover(sender: sender)
        } else {
            showPopover(sender: sender)
        }
    }
    
    func showPopover(sender: Any?) {
        if let button = statusItem.button {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.minY)
        }
        eventMonitor?.start()
    }
    
    func closePopover(sender: Any?) {
        popover.performClose(sender)
        eventMonitor?.stop()
    }
    
    @objc func terminate() {
        NSApp.terminate(nil)
    }
    
}

extension Notification.Name {
    static let killLauncher = Notification.Name("killLauncher")
}

extension UserDefaults {
    
    struct Keys {
        private init() {}
        static let DidEnableStartOnLogin = "didEnableStartOnLogin"
        static let UserCountryIndex = "userCountryIndex"
    }
    
    class func set(didEnableStartOnLogin: Int) {
        let userDefaults = UserDefaults.standard
        userDefaults.set(didEnableStartOnLogin, forKey: UserDefaults.Keys.DidEnableStartOnLogin)
    }
    
    class func set(userCountryIndex: Int) {
        let userDefaults = UserDefaults.standard
        userDefaults.set(userCountryIndex, forKey: UserDefaults.Keys.UserCountryIndex)
    }
    
    class var didEnableStartOnLogin: Int {
        let userDefaults = UserDefaults.standard
        
        if userDefaults.object(forKey: UserDefaults.Keys.DidEnableStartOnLogin) == nil {
            UserDefaults.set(didEnableStartOnLogin: 1)
        }
        
        return userDefaults.integer(forKey: UserDefaults.Keys.DidEnableStartOnLogin)
    }
    
    class var userCountryIndex: Int {
        let userDefaults = UserDefaults.standard
        
        if userDefaults.object(forKey: UserDefaults.Keys.UserCountryIndex) == nil {
            UserDefaults.set(userCountryIndex: -1)
        }
        
        return userDefaults.integer(forKey: UserDefaults.Keys.UserCountryIndex)
    }
    
    class func clearUserData() {
        let domain = Bundle.main.bundleIdentifier!
        UserDefaults.standard.removePersistentDomain(forName: domain)
    }
    
}

