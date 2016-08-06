//
//  DragAndDropView.swift
//  FoldersComparator
//
//  Created by Evgeniy Gurtovoy on 8/1/16.
//
//

import Cocoa

class DragAndDropView: NSView {
    
    typealias URLChangedHandler = ((folderURL: NSURL?) -> ())?
    var handler: URLChangedHandler
    var enabled: Bool = true

    private var droppedFolderURL: NSURL?
    private var highlighted = false {
        didSet {
            self.setNeedsDisplayInRect(bounds)
        }
    }
    
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

extension DragAndDropView {
    
    private func setup() {
        self.registerForDraggedTypes([NSFilenamesPboardType])
    }
    
    override func drawRect(dirtyRect: NSRect) {
        super.drawRect(dirtyRect)
        if self.highlighted {
            NSBezierPath.setDefaultLineWidth(5.0)
            NSColor(calibratedRed: 100.0/255.0, green: 200.0/255.0, blue: 250.0/255, alpha: 1).set()
            NSBezierPath.strokeRect(dirtyRect)
        }
    }
    
    override func draggingEntered(sender: NSDraggingInfo) -> NSDragOperation {
        if !self.enabled { return .None }
        let resultBlockWithPath: ((String?) -> NSDragOperation) = {[weak self] path in
            if let strongSelf = self {
                if let folderPath = path {
                    strongSelf.droppedFolderURL = NSURL(fileURLWithPath: folderPath)
                } else {
                    strongSelf.droppedFolderURL = nil
                }
                strongSelf.highlighted = path != nil
                return path != nil ? .Every : .None;
            } else {
                return .None;
            }
        }
        
        let pasteboard = sender.draggingPasteboard()
        guard let pasteboardTypes = pasteboard.types where pasteboardTypes.contains(NSFilenamesPboardType),
            let paths = pasteboard.propertyListForType(NSFilenamesPboardType) as? [String] else {
                return resultBlockWithPath(nil)
        }
        
        let workspace = NSWorkspace.sharedWorkspace()
        for path in paths {
            do {
                let utiType = try workspace.typeOfFile(path)
                if workspace.type(utiType, conformsToType: kUTTypeFolder as String) {
                    return resultBlockWithPath(path)
                }
            } catch {}
        }
        return resultBlockWithPath(nil)
    }
    
    override func draggingExited(sender: NSDraggingInfo?) {
        self.highlighted = false
        self.droppedFolderURL = nil
    }
    
    override func performDragOperation(sender: NSDraggingInfo) -> Bool {
        self.highlighted = false
        self.handler?(folderURL: droppedFolderURL)
        return true
    }
    
    func folderHasCustomIcon(path: String) -> Bool {
        let iconPath = NSString.pathWithComponents([path, "Icon\r"])
        return NSFileManager.defaultManager().fileExistsAtPath(iconPath)
    }
}