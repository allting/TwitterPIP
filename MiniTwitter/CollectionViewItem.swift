//
//  CollectionViewItem.swift
//  MiniTwitter
//
//  Created by kkr on 25/03/2017.
//  Copyright © 2017 allting. All rights reserved.
//

import Cocoa

protocol  CollectionViewItemDelegate: class{
    func selectFavoriteButton(tweet: Tweet)
    func selectReplyButton(tweet: Tweet)
    func selectRetweetButton(tweet: Tweet)
    func selectShareButton(tweet: Tweet)
}

class CollectionViewItem: NSCollectionViewItem {
    var tweet: Tweet?
    @IBOutlet var textTweet: NSTextField?
    @IBOutlet var createdAt: NSTextField?

    weak var delegate: CollectionViewItemDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor.clear.cgColor

        textTweet?.allowsEditingTextAttributes = true
        textTweet?.isSelectable = true
    }
    
    @IBAction func selectedFavoriteButton(_ sendedr: Any){
        print("selected fav")
        self.delegate?.selectFavoriteButton(tweet: self.tweet!)
    }
    @IBAction func selectedReplyButton(_ sendedr: Any){
        print("selected reply")
        self.delegate?.selectReplyButton(tweet: self.tweet!)
    }
    @IBAction func selectedRetweetButton(_ sendedr: Any){
        print("selected retweet")
        self.delegate?.selectRetweetButton(tweet: self.tweet!)
    }
    @IBAction func selectedShareButton(_ sendedr: Any){
        print("selected share")
        self.delegate?.selectShareButton(tweet: self.tweet!)
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
