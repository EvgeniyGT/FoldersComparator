//
//  NSFileManagerExtentions.swift
//  FoldersComparator
//
//  Created by Evgeniy Gurtovoy on 8/4/16.
//
//

import Cocoa

extension NSFileManager {
    
    func isDirectoryAtURL(url: NSURL) -> Bool {
        var isDir : ObjCBool = false
        if let urlPath = url.path {
            if fileExistsAtPath(urlPath, isDirectory:&isDir) {
                if isDir {
                    return true
                }
            }
        }
        return false
    }
    
    func fileContentsChecksum(path: String?) -> String? {
        guard let filePath = path else {
            return nil
        }
        let checksum = NSData(contentsOfFile: filePath)?.MD5().hexedString()
        return checksum
    }
    
    func sizeForLocalFilePath(path: String?) -> UInt64 {
        guard let filePath = path else {
            return 0
        }
        do {
            let attr : NSDictionary? = try self.attributesOfItemAtPath(filePath)
            if let _attr = attr {
                return _attr.fileSize()
            }
        } catch {
            print("Failed to get file attributes for local path: \(filePath) with error: \(error)")
        }
        return 0
    }
}

