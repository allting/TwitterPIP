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
        window.styleMask.insert(.fullSizeContentView)
        window.titleVisibility = .hidden
        window.titlebarAppearsTransparent = true
        window.isMovableByWindowBackground = true
        
        contentView = window.contentView as! NSVisualEffectView
        
//        self.contentView?.blendingMode = NSVisualEffectBlendingMode.behindWindow
//        self.contentView?.state = NSVisualEffectState.active
  
//        let blurryView = NSVisualEffectView(frame: NSRect(x: 0, y: 0, width: 800, height: 600))
//        blurryView.blendingMode = NSVisualEffectBlendingMode.behindWindow
//        blurryView.material = NSVisualEffectMaterial.dark
//        blurryView.state = NSVisualEffectState.active
//        
//        window.contentView?.addSubview(blurryView)
        
        WAYTheDarkSide.welcomeApplication({
            self.window.appearance = NSAppearance.init(named: NSAppearanceNameVibrantDark)
            self.contentView?.blendingMode = NSVisualEffectBlendingMode.behindWindow
            self.contentView?.material = NSVisualEffectMaterial.dark
            self.contentView?.state = NSVisualEffectState.active
        }, immediately: true)
        
        WAYTheDarkSide.outcastApplication({ 
            self.window?.appearance = NSAppearance.init(named: NSAppearanceNameVibrantLight);
            self.contentView?.blendingMode = NSVisualEffectBlendingMode.behindWindow
            self.contentView?.material = NSVisualEffectMaterial.light
            self.contentView?.state = NSVisualEffectState.active
        }, immediately: true)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }


}

