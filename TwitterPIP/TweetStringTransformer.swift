//
//  TweetStringTransformer.swift
//  TwitterPIP
//
//  Created by kkr on 24/06/2017.
//  Copyright © 2017 allting. All rights reserved.
//

import Cocoa

class TweetStringTransformer: ValueTransformer {
    override class func transformedValueClass() -> AnyClass {
        return NSAttributedString.self
    }
    
    override class func allowsReverseTransformation() -> Bool {
        return true
    }
    
    override func transformedValue(_ value: Any?) -> Any? {
        guard let string = value as? String else { return nil }

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
    
    override func reverseTransformedValue(_ value: Any?) -> Any? {
        guard let attr = value as? NSAttributedString else { return nil }
        return attr.string
    }
}
