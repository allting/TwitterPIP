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
    
    override var representedObject: Any? {
        didSet {
            applyButtonState()
        }
    }
    
    fileprivate func applyButtonState(){
        guard let tweet = self.representedObject as? Tweet else { return }
        
        self.favoriteButton?.state = tweet.favorited! ? NSOnState : NSOffState
        self.retweetButton?.state = tweet.retweeted! ? NSOnState : NSOffState
        
        print("But:\(String(describing: self.favoriteButton)), Fav:\(tweet.favorited!), Ret:\(tweet.retweeted!)")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor.clear.cgColor

        textTweet?.allowsEditingTextAttributes = true
        textTweet?.isSelectable = true
        
        menuStackView?.detachesHiddenViews = true
//        applyButtonState()
        self.hideMenu()
    }
    
    func showMenu() {
        self.menuStackView?.showViews(views: (self.menuStackView?.views)!, animated: true);
    }
    
    func hideMenu() {
        self.menuStackView?.hideViews(views: (self.menuStackView?.views)!, animated: true);
    }
    
    override func viewDidLayout() {
        super.viewDidLayout()
        textTweet?.invalidateIntrinsicContentSize()
    }
    
    @IBAction func selectedFavorite(_ sender: AnyObject) {
        guard let tweet = self.representedObject as? Tweet else { return }
        
        let userInfo: [String: Any] = ["Tweet": tweet as AnyObject, "Action": "Favorite"]
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "TweetAction"), object: self, userInfo: userInfo)
        
        tweet.favorited = !tweet.favorited
        self.favoriteButton?.state = tweet.favorited! ? NSOnState : NSOffState
    }

    @IBAction func selectedReply(_ sender: AnyObject) {
        guard let tweet = self.representedObject as? Tweet else { return }
        
        let userInfo: [String: Any] = ["Tweet": tweet as AnyObject, "Action": "Reply"]
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "TweetAction"), object: self, userInfo: userInfo)
    }

    @IBAction func selectedRetweet(_ sender: AnyObject) {
        guard let tweet = self.representedObject as? Tweet else { return }
        
        let userInfo: [String: Any] = ["Tweet": tweet as AnyObject, "Action": "Retweet"]
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "TweetAction"), object: self, userInfo: userInfo)

        tweet.retweeted = !tweet.retweeted
        self.retweetButton?.state = tweet.retweeted! ? NSOnState : NSOffState
    }

    @IBAction func selectedShare(_ sender: AnyObject) {
        guard let tweet = self.representedObject as? Tweet else { return }
        
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


extension NSStackView {
    
    func hideViews(views: [NSView], animated: Bool) {
        views.forEach { view in
            view.isHidden = true
        }
        if animated {
            NSAnimationContext.runAnimationGroup({ context in
                context.duration = 0.3
                context.allowsImplicitAnimation = true
                self.window?.layoutIfNeeded()
                
            }, completionHandler: nil)
        }
    }
    
    func showViews(views: [NSView], animated: Bool) {
        views.forEach { view in
            // unhide the view so the stack view knows how to layout…
            view.isHidden = false
            
            if animated {
                view.wantsLayer = true
                // …but set opacity to 0 so the view is not visible during the animation
                view.layer!.opacity = 0.0
            }
        }
        
        if animated {
            NSAnimationContext.runAnimationGroup({ context in
                context.duration = 0.3
                context.allowsImplicitAnimation = true
                self.window?.layoutIfNeeded()
                
            }, completionHandler: {
                // reset opacity to show the views after the animation finished
                views.forEach { view in
                    view.layer!.opacity = 1.0
                }
            })
        }
    }
}
