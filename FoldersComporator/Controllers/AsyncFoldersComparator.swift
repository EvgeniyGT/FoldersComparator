//
//  AsyncFoldersComparator.swift
//  FoldersComparator
//
//  Created by Evgeniy Gurtovoy on 8/4/16.
//
//

import Foundation

// MARK: - Protocols

typealias AsyncFoldersResultHandler = ((comparationResult: ComparationResult) -> ())?

protocol AsyncFoldersComparatorProvider {
    var comparisonProvider: FoldersСomparisonProvider { get }
    var backgroudQueueProvider: BackgroudQueueProvider { get }
    
    func compareTwoFolders(leftFolderURL: NSURL, rightFolderURL: NSURL, resultHandler: AsyncFoldersResultHandler)
    func cancelComparison()
}

protocol BackgroudQueueProvider {
    func addOperation(op: NSOperation)
    func cancelAllOperations()
}

// MARK: - AsyncFoldersComparator

class AsyncFoldersComparator {
    
    private(set) var comparisonProvider: FoldersСomparisonProvider
    private(set) var backgroudQueueProvider: BackgroudQueueProvider
    
    init(comparisonProvider: FoldersСomparisonProvider,
         backgroudQueueProvider: BackgroudQueueProvider = NSOperationQueue()) {
        self.comparisonProvider = comparisonProvider
        self.backgroudQueueProvider = backgroudQueueProvider
    }
}

// MARK: - AsyncFoldersComparatorProvider Implementation

extension AsyncFoldersComparator: AsyncFoldersComparatorProvider {
    
    func compareTwoFolders(leftFolderURL: NSURL, rightFolderURL: NSURL, resultHandler: AsyncFoldersResultHandler) {
        let blockOperation = NSBlockOperation()
        blockOperation.addExecutionBlock { () -> Void in
            let result = self.comparisonProvider.compareTwoFolders(leftFolderURL, rightFolderURL: rightFolderURL)
            NSOperationQueue.mainQueue().addOperationWithBlock {
                resultHandler?(comparationResult: result)
            }
        }
        self.backgroudQueueProvider.addOperation(blockOperation)
    }

    func cancelComparison() {
        self.comparisonProvider.cancelComparison()
        self.backgroudQueueProvider.cancelAllOperations()
    }
}

extension NSOperationQueue : BackgroudQueueProvider {}