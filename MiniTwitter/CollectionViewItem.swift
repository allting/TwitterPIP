//
//  CollectionViewItem.swift
//  MiniTwitter
//
//  Created by kkr on 25/03/2017.
//  Copyright © 2017 allting. All rights reserved.
//

import Cocoa

class CollectionViewItem: NSCollectionViewItem {

//    var imageFile: ImageFile? {
//        didSet{
//            guard isViewLoaded else { return }
//            if let imageFile = imageFile {
//                imageView?.image = imageFile.thumbnail
//                textField?.stringValue = imageFile.fileName
//            }else{
//                imageFile?.image = nil
//                textField?.stringValue = ""
//            }
//        }
//    }
    
    @IBOutlet var textTweet: NSTextField?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor.clear.cgColor
//        textField?.backgroundColor = NSColor.clear
//        textTweet?.backgroundColor = NSColor.clear
    }
}
