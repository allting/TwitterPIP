//
//  HeaderView.swift
//  TwitterPIP
//
//  Created by kkr on 24/06/2017.
//  Copyright © 2017 allting. All rights reserved.
//

import Cocoa

class HeaderView: NSView {
    lazy var searchField: NSSearchField? = {
        for view in self.subviews {
            if view is NSSearchField {
                return view as? NSSearchField
            }
        }
        return nil
    }()
}
