//
//  FoldersСomparisonСontroller.swift
//  FoldersComparator
//
//  Created by Evgeniy Gurtovoy on 8/4/16.
//
//

import Foundation

// MARK: - Comparation Result

enum ComparationResult {
    case ComparationCancelled
    case ComparationFinished(result: Bool)
}

func == (lhs: ComparationResult, rhs: ComparationResult) -> Bool {
    switch lhs {
    case .ComparationCancelled:
        switch rhs {
        case .ComparationCancelled: return true
        default: return false
        }
    case let .ComparationFinished(sameFoldersLhs):
        switch rhs {
        case let .ComparationFinished(sameFoldersRhs) : return sameFoldersLhs == sameFoldersRhs
        default: return false
        }
    }
}

// MARK: - File Node

private struct FileNode {
    let nodeURL: NSURL
}

private class FileNodesFactory {
    static func fileNodeFromURL(url: NSURL) -> FileNode {
        return FileNode(nodeURL: url)
    }
    static func fileNodesFromURLs(urls: [NSURL]) -> [FileNode] {
        return urls.map({fileNodeFromURL($0)})
    }
}

// MARK: - Protocols

protocol FoldersСomparisonProvider {
    var diskControllerProvider: DiskControllerProvider { get }
    var filterControllerProvider: FilesFilterProvider { get }
    var filesComporatorProvider: FilesСomparisonProvider { get }
    var comparisonCancelled: Bool { get }
    
    func compareTwoFolders(leftFolderURL: NSURL, rightFolderURL: NSURL) -> ComparationResult
    func cancelComparison()
}

protocol DiskControllerProvider {
    func isDirectoryAtURL(url: NSURL) -> Bool
    func contentsOfDirectoryAtURL(url: NSURL, includingPropertiesForKeys keys: [String]?, options mask: NSDirectoryEnumerationOptions) throws -> [NSURL]
    func fileContentsChecksum(path: String?) -> String?
    func sizeForLocalFilePath(path: String?) -> UInt64
}

class FoldersСomparisonСontroller {
    
    private(set) var diskControllerProvider: DiskControllerProvider
    private(set) var filterControllerProvider: FilesFilterProvider
    private(set) var filesComporatorProvider: FilesСomparisonProvider
    private(set) var comparisonCancelled: Bool = false
    
    init(diskControllerProvider: DiskControllerProvider = NSFileManager.defaultManager(),
        filesComporatorProvider: FilesСomparisonProvider = FilesСomparisonСontroller(),
        filterControllerProvider: FilesFilterProvider) {
        
        self.diskControllerProvider = diskControllerProvider
        self.filesComporatorProvider = filesComporatorProvider
        self.filterControllerProvider = filterControllerProvider
    }
}

// MARK: - FoldersСomparisonProvider Implementation

extension FoldersСomparisonСontroller: FoldersСomparisonProvider {
    
    func compareTwoFolders(leftFolderURL: NSURL, rightFolderURL: NSURL) -> ComparationResult {
        self.comparisonCancelled = false
        
        let leftFileNode = FileNodesFactory.fileNodeFromURL(leftFolderURL)
        let rightFileNode = FileNodesFactory.fileNodeFromURL(rightFolderURL)

        let sameFolders = self.getDiff(leftFileNode: leftFileNode, rightNode: rightFileNode)
        return self.comparisonCancelled ? .ComparationCancelled : .ComparationFinished(result: sameFolders)
    }
    
    func cancelComparison() {
        self.comparisonCancelled = true
    }
}

// MARK: - Private

private extension FoldersСomparisonСontroller {
    
    private func getDiff(leftFileNode leftNode: FileNode, rightNode: FileNode) -> Bool {
        if (self.comparisonCancelled) {
            return false
        }
        
        let nodesContent = self.filteredNodesContents(_: leftNode, rightNode: rightNode)
        if (nodesContent.leftNodeChildsURLs.count != nodesContent.rightNodeChildsURLs.count) {
            return false
        }
        
        let leftNodeContents = FileNodesFactory.fileNodesFromURLs(nodesContent.leftNodeChildsURLs)
        let rightNodeContents = FileNodesFactory.fileNodesFromURLs(nodesContent.rightNodeChildsURLs)
        
        return self.compareContents(_: leftNodeContents, rightNodeContents: rightNodeContents)
    }
    
    private func compareContents(leftNodeContents: [FileNode], rightNodeContents: [FileNode]) -> Bool {
        if (self.comparisonCancelled) {
            return false
        }

        for i in 0 ..< leftNodeContents.count {
            let fileNode = leftNodeContents[i]
            var matchIsFound = false
            for j in 0 ..< leftNodeContents.count {
                if self.compareFileNodes(_: fileNode, rightNode: rightNodeContents[j]) {
                    matchIsFound = true
                    break
                }
            }
            if !matchIsFound {
                return false
            }
        }
        return true
    }
    
    private func compareFileNodes(leftNode: FileNode, rightNode: FileNode) -> Bool {
        if (self.comparisonCancelled) {
            return false
        }
        
        if (self.diskControllerProvider.isDirectoryAtURL(leftNode.nodeURL) && !self.diskControllerProvider.isDirectoryAtURL(rightNode.nodeURL) ||
            !self.diskControllerProvider.isDirectoryAtURL(leftNode.nodeURL) && self.diskControllerProvider.isDirectoryAtURL(rightNode.nodeURL)) {
            return false
        }
        if self.diskControllerProvider.isDirectoryAtURL(leftNode.nodeURL) && self.diskControllerProvider.isDirectoryAtURL(rightNode.nodeURL) {

            let nodesContent = filteredNodesContents(_: leftNode, rightNode: rightNode)
            if (nodesContent.leftNodeChildsURLs.count != nodesContent.rightNodeChildsURLs.count) {
                return false
            }

            if !getDiff(leftFileNode: leftNode, rightNode: rightNode) {
                return false
            }
            
        } else {
            
            let filesAreTheSame = filesComporatorProvider.compareTwoFiles(leftNode.nodeURL, rightFileURL: rightNode.nodeURL)
            if !filesAreTheSame {
                return false
            }
        }
        
        return true
    }
    
    private func filteredNodesContents(leftNode: FileNode, rightNode: FileNode) -> (leftNodeChildsURLs: [NSURL], rightNodeChildsURLs: [NSURL]) {
        let leftNodeChildsURLs = (try? self.diskControllerProvider.contentsOfDirectoryAtURL(leftNode.nodeURL,
            includingPropertiesForKeys: nil,
            options: NSDirectoryEnumerationOptions(rawValue: 0))
            ) ?? []
        let rightNodeChildsURLs = (try? self.diskControllerProvider.contentsOfDirectoryAtURL(rightNode.nodeURL,
            includingPropertiesForKeys: nil,
            options: NSDirectoryEnumerationOptions(rawValue: 0))
            ) ?? []
        
        return (self.filterControllerProvider.filterFilesList(leftNodeChildsURLs),
                self.filterControllerProvider.filterFilesList(rightNodeChildsURLs))
    }
}

extension NSFileManager : DiskControllerProvider {}
