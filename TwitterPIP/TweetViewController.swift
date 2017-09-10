//
//  TweetViewController.swift
//  TwitterPIP
//
//  Created by kkr on 18/06/2017.
//  Copyright © 2017 allting. All rights reserved.
//

import Cocoa

class TweetViewController: NSViewController {
    @IBOutlet var contentView: NSVisualEffectView!
    @IBOutlet var replyView: NSTextView?
    @IBOutlet var countLabel: NSTextField?
    var lengthOfTweet: NSInteger = 0
    var remainLengthOfTweet: NSInteger = 140 {
        didSet {
            updateCountLabel();
        }
    }
    
    static var formatter: NumberFormatter = NumberFormatter.init()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        WAYTheDarkSide.welcomeApplication({
            self.view.window?.appearance = NSAppearance.init(named: NSAppearanceNameVibrantDark)
            self.contentView?.blendingMode = NSVisualEffectBlendingMode.behindWindow
            self.contentView?.material = NSVisualEffectMaterial.dark
            self.contentView?.state = NSVisualEffectState.active
        }, immediately: true)
        
        WAYTheDarkSide.outcastApplication({
            self.view.window?.appearance = NSAppearance.init(named: NSAppearanceNameVibrantLight);
            self.contentView?.blendingMode = NSVisualEffectBlendingMode.behindWindow
            self.contentView?.material = NSVisualEffectMaterial.light
            self.contentView?.state = NSVisualEffectState.active
        }, immediately: true)
        
        self.replyView?.backgroundColor = NSColor.clear
        self.replyView?.delegate = self
        self.view.window?.makeFirstResponder(self.replyView)
        
        
        self.countLabel?.formatter = TweetViewController.formatter
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
    
    override var representedObject: Any? {
        didSet {
            guard let tweet = self.representedObject as? Tweet else { return }
            let tweetText = "@" + tweet.screenName + " "
            self.replyView?.textStorage?.setAttributedString(self.attributedString(tweetText))
            self.replyView?.setSelectedRange(NSRange.init(location: tweetText.characters.count, length: 0))
            self.calculateTweetLength()
        }
    }
    
    fileprivate func attributedString(_ string: String) -> NSAttributedString{
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineBreakMode = .byWordWrapping
        paragraphStyle.alignment = .left
        paragraphStyle.lineHeightMultiple = 0
        paragraphStyle.lineSpacing = 3
        
        let attributes: [String: Any] = [NSFontAttributeName: NSFont.systemFont(ofSize: 13.0),
                                         NSForegroundColorAttributeName: NSColor.darkGray,
                                         NSParagraphStyleAttributeName: paragraphStyle]
        
        let attributedString = NSMutableAttributedString.init(string: string, attributes: attributes)
        
        let detector = try! NSDataDetector.init(types: NSTextCheckingResult.CheckingType.link.rawValue)
        let matches = detector.matches(in: string, options: [], range: NSRange(location:0, length:string.utf16.count))
        
        for match in matches {
            let url = (string as NSString).substring(with: match.range)
            let attributes : [String : Any] = ["CUSTOM": url,
                                               NSFontAttributeName: NSFont.systemFont(ofSize: 13.0),
                                               NSForegroundColorAttributeName: NSColor.darkGray,
                                               NSUnderlineStyleAttributeName: NSUnderlineStyle.styleSingle.rawValue,
                                               NSParagraphStyleAttributeName: paragraphStyle,
                                               NSCursorAttributeName: NSCursor.pointingHand()]
            
            attributedString.setAttributes(attributes, range:match.range)
        }
        
        return attributedString
    }

    fileprivate func calculateTweetLength() {
        self.lengthOfTweet = (self.replyView?.string?.characters.count)!
        self.remainLengthOfTweet = 140 - self.lengthOfTweet
    }
    
    fileprivate func updateCountLabel() {
        self.countLabel?.stringValue = String(self.remainLengthOfTweet)
    }
}

extension TweetViewController : NSTextViewDelegate {
    func textView(_ textView: NSTextView, shouldChangeTextInRanges affectedRanges: [NSValue], replacementStrings: [String]?) -> Bool {
        let string = replacementStrings?.first
        let range = affectedRanges.first?.rangeValue
        
        if self.lengthOfTweet < 140 || (string?.characters.count)! < (range?.length)!{
            return true
        }
        
        return false
    }
    
    func textDidChange(_ notification: Notification) {
        calculateTweetLength()
    }
}
