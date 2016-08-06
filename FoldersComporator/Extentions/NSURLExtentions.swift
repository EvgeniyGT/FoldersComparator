//
//  NSURLExtentions.swift
//  FoldersComparator
//
//  Created by Evgeniy Gurtovoy on 8/5/16.
//
//

import Foundation

extension NSURL {
    var typeIdentifier: String? {
        guard fileURL else { return nil }
        var uniformTypeIdentifier: AnyObject?
        do {
            try getResourceValue(&uniformTypeIdentifier, forKey:  NSURLTypeIdentifierKey)
            return uniformTypeIdentifier as? String
        } catch let error as NSError {
            print(error.debugDescription)
            return nil
        }
    }
}