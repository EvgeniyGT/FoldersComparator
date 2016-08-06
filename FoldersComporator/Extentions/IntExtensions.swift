//
//  IntExtensions.swift
//  FoldersComparator
//
//  Created by Evgeniy Gurtovoy on 8/2/16.
//
//

import Foundation

extension Int {
    func hexedString() -> String {
        return NSString(format:"%02x", self) as String
    }
}