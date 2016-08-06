//
//  FolderView.swift
//  FoldersComparator
//
//  Created by Evgeniy Gurtovoy on 8/1/16.
//
//

import Cocoa

class FolderView: NSView {
    
    typealias URLChangedHandler = ((folderView: FolderView) -> ())?
    var handler: URLChangedHandler
    var enabled: Bool = true {
        didSet {
            self.dragAndDropView.enabled = enabled
            self.reloadAppearance()
        }
    }
    private(set) var folderURL: NSURL? = nil {
        didSet {
            self.handler?(folderView: self)
            self.reloadAppearance()
        }
    }
    private let openPanelButton: NSButton = {
        let openPanelButton = NSButton(frame: CGRectZero)
        openPanelButton.setButtonType(.MomentaryChangeButton)
        openPanelButton.bordered = false
        openPanelButton.image = NSImage(named: .folderIconImageName)
        openPanelButton.imagePosition = NSCellImagePosition.ImageAbove
        openPanelButton.translatesAutoresizingMaskIntoConstraints = false
        openPanelButton.action = #selector(openPanelButtonClicked)
        return openPanelButton
    }()
    private let dragAndDropView: DragAndDropView = {
        let dragAndDropView = DragAndDropView(frame: CGRectZero)
        return dragAndDropView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder:aDecoder)
        self.setup()
    }
}

// MARK: - Private

private extension FolderView {
    
    private func setup() {
        wantsLayer = true
        
        // Open Panel Button
        self.openPanelButton.target = self
        self.addSubview(self.openPanelButton)
        self.openPanelButton.autoPinEdgesToSuperviewEdges()
        
        // Drag and Drop View
        self.addSubview(self.dragAndDropView)
        let insets = NSEdgeInsetsMake(-10, 0, 20, 0)
        self.dragAndDropView.autoPinEdgesToSuperviewEdgesWithInsets(insets)
        self.dragAndDropView.handler = self.folderViewURLChanged
        
        // Initial URL value
        self.folderViewURLChanged(nil)
    }
    
    private func reloadAppearance() {
        self.layer?.opacity = self.folderURL != nil ? 1 : 0.5
        
        let folderName = self.folderURL?.URLByDeletingPathExtension?.lastPathComponent
        if let path = self.folderURL?.path {
            let folderIcon = NSWorkspace.sharedWorkspace().iconForFile(path)
            folderIcon.size = CGSize(width: 128, height: 128)
            self.openPanelButton.image = folderIcon
        }
        
        self.openPanelButton.attributedTitle = NSAttributedString()
        if let name = folderName {
            if self.enabled {
                let pstyle = NSMutableParagraphStyle()
                pstyle.alignment = .Center
                let color = NSColor(calibratedRed: 100.0/255.0, green: 200.0/255.0, blue: 250.0/255, alpha: 1)
                let attributes = [NSForegroundColorAttributeName: color,
                                  NSParagraphStyleAttributeName: pstyle]
                self.openPanelButton.attributedTitle = NSAttributedString(string: name, attributes: attributes)
            }
        }
    }
    
    @objc private func openPanelButtonClicked(sender: NSButton) {
        if !self.enabled { return }
        let openPanel = NSOpenPanel()
        openPanel.allowsMultipleSelection = false
        openPanel.canChooseDirectories = true
        openPanel.canCreateDirectories = false
        openPanel.canChooseFiles = false
        openPanel.beginWithCompletionHandler { (result) -> Void in
            if result == NSFileHandlingPanelOKButton {
                self.folderViewURLChanged(openPanel.URL)
            }
        }
    }
    
    private func folderViewURLChanged(url: NSURL?) {
        self.folderURL = url
    }
}

private typealias ImageNames = String
private extension ImageNames {
    static let folderIconImageName = "folder-icon"
}
