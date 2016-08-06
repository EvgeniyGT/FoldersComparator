//
//  FilesСomparisonСontroller.swift
//  FoldersComparator
//
//  Created by Evgeniy Gurtovoy on 8/5/16.
//
//

import Foundation

// MARK: - Protocols

protocol FilesСomparisonProvider {
    var diskControllerProvider: DiskControllerProvider { get }
    
    func compareTwoFiles(leftFileURL: NSURL, rightFileURL: NSURL) -> Bool
}

class FilesСomparisonСontroller: FilesСomparisonProvider {
    
    private(set) var diskControllerProvider: DiskControllerProvider
    
    init(diskControllerProvider: DiskControllerProvider = NSFileManager.defaultManager()) {
        self.diskControllerProvider = diskControllerProvider
    }
}

// MARK: - FilesСomparisonProvider DefaultImplementation

extension FilesСomparisonProvider {
    
    func compareTwoFiles(leftFileURL: NSURL, rightFileURL: NSURL) -> Bool {
        
        // File Sizes
        let leftFileSize = self.diskControllerProvider.sizeForLocalFilePath(leftFileURL.path)
        let rightFileSize = self.diskControllerProvider.sizeForLocalFilePath(rightFileURL.path)
        if ((leftFileSize != rightFileSize) && (leftFileSize > 0 && rightFileSize > 0)) {
            return false
        }
        
        // UTI
        let leftFileTypeID = leftFileURL.typeIdentifier
        let rightFileTypeID = rightFileURL.typeIdentifier;
        if let leftFileUTI = leftFileTypeID, let rightFileUTI = rightFileTypeID {
            if leftFileUTI != rightFileUTI {
                return false
            }
        }
        
        // MD5
        let leftFileChecksum = self.diskControllerProvider.fileContentsChecksum(leftFileURL.path)
        let rightFileChecksum = self.diskControllerProvider.fileContentsChecksum(rightFileURL.path)
        return leftFileChecksum == rightFileChecksum
    }
}
