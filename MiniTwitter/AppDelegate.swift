//
//  AppDelegate.swift
//  MiniTwitter
//
//  Created by kkr on 25/03/2017.
//  Copyright © 2017 allting. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    var window: NSWindow!
    var contentView: NSVisualEffectView!
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        window = NSApplication.shared().windows.last!
        contentView = window.contentView as! NSVisualEffectView

        WAYTheDarkSide.welcomeApplication({ 
            self.window.appearance = NSAppearance.init(named: NSAppearanceNameVibrantDark)
            self.contentView?.material = NSVisualEffectMaterial.dark
        }, immediately: true)
        
        WAYTheDarkSide.outcastApplication({ 
            self.window?.appearance = NSAppearance.init(named: NSAppearanceNameVibrantLight);
            self.contentView.material = NSVisualEffectMaterial.light
        }, immediately: true)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }


}

