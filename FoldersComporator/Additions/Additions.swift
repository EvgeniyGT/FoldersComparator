//
//  Additions.swift
//  FoldersComparator
//
//  Created by Evgeniy Gurtovoy on 8/3/16.
//
//

import Foundation

class Util {
    static func runAfterDelay(delay: NSTimeInterval, block: dispatch_block_t) {
        let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay * Double(NSEC_PER_SEC)))
        dispatch_after(time, dispatch_get_main_queue(), block)
    }
}

