//
//  FilesFilterController.swift
//  FoldersComparator
//
//  Created by Evgeniy Gurtovoy on 8/5/16.
//
//

import Foundation

// MARK: - Protocols

protocol FilesFilterProvider {
    var ignoredFilesExtentionsList: [String] { get }
    
    func filterFilesList(list: [NSURL]) -> [NSURL]
}

class FilesFilterController: FilesFilterProvider {
    
    private(set) var ignoredFilesExtentionsList: [String]
    
    init(ignoredFilesExtentions: [String]) {
        self.ignoredFilesExtentionsList = ignoredFilesExtentions
    }
}

// MARK: - FilesFilterProvider DefaultImplementation

extension FilesFilterProvider {
    
    func filterFilesList(list: [NSURL]) -> [NSURL] {
        return list.flatMap({ pathURL in
            if let lastPathComponent = pathURL.lastPathComponent {
                if let extention = lastPathComponent.componentsSeparatedByString(".").last {
                    return self.ignoredFilesExtentionsList.contains({$0.lowercaseString == extention.lowercaseString}) ? nil : pathURL
                }
            }
            return nil
        })
    }
}