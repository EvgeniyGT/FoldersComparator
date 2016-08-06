//
//  MainViewController.swift
//  FoldersComparator
//
//  Created by Evgeniy Gurtovoy on 8/1/16.
//
//

import Cocoa

// MARK: - UIState ViewModel

private struct UIStateViewModel {
    var scanButtonHidden: Bool
    var cancelButtonHidden: Bool
    var stateMessage: UserMessage
    var stateMessageColor: NSColor?
}

// MARK: - UI State

private enum UIState {
    case Undefined
    case WaitingForContent
    case ReadyToScan
    case Scanning
    case ScanResult(ComparationResult)
    
    func viewModel() -> UIStateViewModel {
        var viewModel = UIStateViewModel(scanButtonHidden: true,
                                         cancelButtonHidden: true,
                                         stateMessage: "",
                                         stateMessageColor: nil)
        switch self {
        case .Undefined: break
        case .WaitingForContent:
            viewModel.stateMessage = .selectFoldersMessage
        case .ReadyToScan:
            viewModel.scanButtonHidden = false
            viewModel.stateMessage = .readyToScanMessage
        case .Scanning:
            viewModel.cancelButtonHidden = false
            viewModel.stateMessage = .scanningMessage
        case let .ScanResult(comparationResult):
            switch comparationResult {
            case .ComparationCancelled:
                viewModel.stateMessage = .scanningCancelledMessage
                viewModel.stateMessageColor = NSColor.orangeColor()
            case .ComparationFinished(let sameFolders):
                if sameFolders {
                    viewModel.stateMessage = .scanningFinishedSuccessMessage
                    viewModel.stateMessageColor = NSColor.greenColor()
                } else {
                    viewModel.stateMessage = .scanningFinishedFailMessage
                    viewModel.stateMessageColor = NSColor.redColor()
                }
            }
            viewModel.scanButtonHidden = false
        }
        return viewModel
    }
}

private func == (lhs: UIState, rhs: UIState) -> Bool {
    switch lhs {
    case .Undefined:
        switch rhs {
        case .Undefined: return true
        default: return false
        }
    case .WaitingForContent:
        switch rhs {
        case .WaitingForContent: return true
        default: return false
        }
    case .ReadyToScan:
        switch rhs {
        case .ReadyToScan: return true
        default: return false
        }
    case .Scanning:
        switch rhs {
        case .Scanning: return true
        default: return false
        }
    case let .ScanResult(comparationResultLhs):
        switch rhs {
        case let .ScanResult(comparationResultRhs) : return comparationResultLhs == comparationResultRhs
        default: return false
        }
    }
}

class MainViewController: NSViewController {
    
    private var state: UIState = .Undefined
    private lazy var foldersMergeAnimator: FoldersMergeAnimator = {
        let animator = FoldersMergeAnimator(leftFolderAnimatableConsrtraint: self.leftFolderCenterXConstraint,
                                            rightFolderAnimatableConsrtraint: self.rightFolderCenterXConstraint,
                                            parentView: self.view)
        return animator
    }()
    private lazy var xRayAnimator: XRayAnimator = {
        let animator = XRayAnimator(xRayImageView: self.xRayImageView, parentView: self.view)
        return animator
    }()
    private lazy var asyncFoldersComparator: AsyncFoldersComparator = {
        let filesFilterController = FilesFilterController(ignoredFilesExtentions: ["DS_Store"])
        let foldersСomparisonСontroller = FoldersСomparisonСontroller(filterControllerProvider: filesFilterController)
        let asyncFoldersComparator = AsyncFoldersComparator(comparisonProvider: foldersСomparisonСontroller)
        return asyncFoldersComparator
    }()
    
    @IBOutlet private weak var xRayImageView: NSImageView!
    @IBOutlet private weak var leftFolderView: FolderView!
    @IBOutlet private weak var rightFolderView: FolderView!
    @IBOutlet private weak var messageTextField: NSTextField!
    @IBOutlet private weak var cancelButton: NSButton!
    @IBOutlet private weak var scanButton: NSButton!
    @IBOutlet private weak var leftFolderCenterXConstraint: NSLayoutConstraint!
    @IBOutlet private weak var rightFolderCenterXConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.wantsLayer = true
        
        self.reloadUI(.WaitingForContent);
        self.addFolderURLChangesObserver()
    }
}

// MARK: - Private

private extension MainViewController {
    
    private func addFolderURLChangesObserver() {
        func checkForFoldersStatus() {
            let readyToScan = self.leftFolderView.folderURL != nil &&
                self.rightFolderView.folderURL != nil
            self.reloadUI(readyToScan ? .ReadyToScan : .WaitingForContent)
        }
        self.leftFolderView.handler = { folderView in
            checkForFoldersStatus()
        }
        self.rightFolderView.handler = { folderView in
            checkForFoldersStatus()
        }
    }
    
    private func reloadUI(updatedState: UIState) {
        if self.state == updatedState { return }
        self.state = updatedState
        
        let stateViewModel = self.state.viewModel()
        self.scanButton.hidden = stateViewModel.scanButtonHidden
        self.cancelButton.hidden = stateViewModel.cancelButtonHidden
        self.messageTextField.stringValue = stateViewModel.stateMessage
        self.messageTextField.textColor = stateViewModel.stateMessageColor
    }
    
    private func foldersComparatorFinished(comparationResult: ComparationResult) {
        self.xRayAnimator.removeAnimation({
            self.foldersMergeAnimator.constraintsToInitValue(completion: nil)
            self.leftFolderView.enabled = true
            self.rightFolderView.enabled = true
            self.reloadUI(.ScanResult(comparationResult))
        })
    }
    
    @IBAction private func cancelButtonClicked(sender: AnyObject) {
        self.asyncFoldersComparator.cancelComparison()
    }
    
    @IBAction private func scanButtonClicked(sender: AnyObject) {
        self.reloadUI(.Scanning)
        self.foldersMergeAnimator.constraintsToZero(completion: {
            self.leftFolderView.enabled = false
            self.rightFolderView.enabled = false
            guard let leftFolderURL = self.leftFolderView.folderURL, let rightFolderURL = self.rightFolderView.folderURL else {
                self.reloadUI(.WaitingForContent)
                return
            }
            self.xRayAnimator.animate()
            self.asyncFoldersComparator.compareTwoFolders(_: leftFolderURL, rightFolderURL: rightFolderURL, resultHandler:self.foldersComparatorFinished)
        })
    }
}

private typealias UserMessage = String
private extension UserMessage {
    static let selectFoldersMessage = "Please, select or drag'n'drop folders to compare."
    static let readyToScanMessage = "Ready to scan."
    static let scanningMessage = "Scanning..."
    static let scanningCancelledMessage = "Scanning was cancelled..."
    static let scanningFinishedSuccessMessage = "Scanning finished. Folders are the same."
    static let scanningFinishedFailMessage = "Scanning finished. Folders are different."
}

