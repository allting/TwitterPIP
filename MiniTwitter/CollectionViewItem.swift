//
//  CollectionViewItem.swift
//  MiniTwitter
//
//  Created by kkr on 25/03/2017.
//  Copyright © 2017 allting. All rights reserved.
//

import Cocoa

class CollectionViewItem: NSCollectionViewItem {
    fileprivate var _tweet: Tweet?
    var tweet: Tweet? {
        set {
            self.textTweet?.attributedStringValue = newValue!.text
            self.textField?.stringValue = newValue!.name
            _tweet = newValue
        }
        get {
            return _tweet
        }
    }
    
    fileprivate var _indexPath : IndexPath?
    
    @IBOutlet var textTweet: NSTextField?
    @IBOutlet var createdAt: NSTextField?

    @IBOutlet var menuStackView: NSStackView?
    @IBOutlet var favoriteButton: NSButton?
    @IBOutlet var replyButton: NSButton?
    @IBOutlet var retweetButton: NSButton?
    @IBOutlet var shareButton: NSButton?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor.clear.cgColor

        textTweet?.allowsEditingTextAttributes = true
        textTweet?.isSelectable = true
    }
    
    
    func showMenu() {
//        self.menuStackView?.setVisibilityPriority(NSStackViewVisibilityPriorityMustHold, for: self.view)
//        self.menuStackView?.isHidden = false
    }
    
    func hideMenu() {
//        self.menuStackView?.setVisibilityPriority(NSStackViewVisibilityPriorityNotVisible, for: self.view)
//        self.menuStackView?.hidden = true
    }
    
    @IBAction func selectedFavorite(_ sender: AnyObject) {
        let userInfo: [String: Any] = ["Tweet": tweet as AnyObject, "Action": "Favorite"]
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "TweetAction"), object: self, userInfo: userInfo)
    }

    @IBAction func selectedReply(_ sender: AnyObject) {
        let userInfo: [String: Any] = ["Tweet": tweet as AnyObject, "Action": "Reply"]
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "TweetAction"), object: self, userInfo: userInfo)
    }

    @IBAction func selectedRetweet(_ sender: AnyObject) {
        let userInfo: [String: Any] = ["Tweet": tweet as AnyObject, "Action": "Retweet"]
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "TweetAction"), object: self, userInfo: userInfo)
    }

    @IBAction func selectedShare(_ sender: AnyObject) {
        let userInfo: [String: Any] = ["Tweet": tweet as AnyObject, "Action": "Share"]
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "TweetAction"), object: self, userInfo: userInfo)
    }
}

class MyTextField: NSTextField {
    
    var referenceView: NSTextView {
        let theRect = self.cell!.titleRect(forBounds: self.bounds)
        let tv = NSTextView(frame: theRect)
        tv.textStorage!.setAttributedString(self.attributedStringValue)
        return tv
    }
    
    override func mouseDown(with event: NSEvent) {
        let point = self.convert(event.locationInWindow, from: nil)
        let charIndex = referenceView.textContainer!.textView!.characterIndexForInsertion(at: point)
        if charIndex < self.attributedStringValue.length {
            let attributes = self.attributedStringValue.attributes(at: charIndex, effectiveRange: nil)
            if let link = attributes["CUSTOM"] as? String {
                NSWorkspace.shared().open(URL(string: link)!)
            }
        }
        super.mouseDown(with: event)
    }
    
}
