//
//  CollectionViewItem.swift
//  MiniTwitter
//
//  Created by kkr on 25/03/2017.
//  Copyright © 2017 allting. All rights reserved.
//

import Cocoa

class CollectionViewItem: NSCollectionViewItem {
    @IBOutlet var textTweet: NSTextField?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor.clear.cgColor

        textTweet?.allowsEditingTextAttributes = true
        textTweet?.isSelectable = true
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
