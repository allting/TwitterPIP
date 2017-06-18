//
//  TweetViewController.swift
//  MiniTwitter
//
//  Created by kkr on 18/06/2017.
//  Copyright © 2017 allting. All rights reserved.
//

import Cocoa

class TweetViewController: NSViewController {
    @IBOutlet var replyView: NSTextView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }

    @IBAction func replyTweet(_ sender: Any) {
        guard let tweet = self.representedObject as? Tweet else { return }
        let reply = replyView?.string
        
        let userInfo: [String: Any] = ["Tweet": tweet as AnyObject, "Reply": reply as AnyObject, "Sender": self.view]
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "ReplyAction"), object: self, userInfo: userInfo)
    }

    @IBAction func cancel(_ sender: Any) {
        self.view.window?.close()
    }
}
