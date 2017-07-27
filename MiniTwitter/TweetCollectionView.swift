//
//  TweetCollectionView.swift
//  MiniTwitter
//
//  Created by kkr on 27/07/2017.
//  Copyright © 2017 allting. All rights reserved.
//

import Cocoa

class TweetCollectionView: NSCollectionView {

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }
 
    override func performKeyEquivalent(with event: NSEvent) -> Bool {
        return true
    }
}
