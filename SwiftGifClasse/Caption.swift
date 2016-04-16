//
//  Caption.swift
//  SwiftGif
//
//  Created by WANG Michael on 4/15/16.
//  Copyright © 2016 Arne Bahlo. All rights reserved.
//

import Foundation
import UIKit


class Caption {
    
    var rangeInGIF: NSRange?
    var text: NSString = NSString()
    var font: UIFont = UIFont(name: "Arial", size: 8)!
    
    
    init (text: NSString) {
        
        self.text = text
    }
    
}