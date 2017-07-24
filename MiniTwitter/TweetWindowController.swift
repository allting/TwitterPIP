//
//  TweetWindowController.swift
//  MiniTwitter
//
//  Created by kkr on 20/07/2017.
//  Copyright © 2017 allting. All rights reserved.
//

import Cocoa

class TweetWindowController: NSWindowController {
    override func windowDidLoad() {
        super.windowDidLoad()

        self.window?.styleMask.insert(.fullSizeContentView)
        self.window?.titleVisibility = .hidden
        self.window?.titlebarAppearsTransparent = true
        self.window?.isMovableByWindowBackground = true
        self.window?.level = Int(CGWindowLevelForKey(.floatingWindow))
        
        self.window!.standardWindowButton(NSWindowButton.zoomButton)?.isEnabled = false
    }
}
