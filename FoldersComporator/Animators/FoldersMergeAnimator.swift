//
//  FoldersMergeAnimator.swift
//  FoldersComparator
//
//  Created by Evgeniy Gurtovoy on 8/2/16.
//
//

import Cocoa

protocol ConstraintsToZeroAnimator {
    weak var viewForLayout: NSView? { get }
    weak var leftAnimatableConstraint: NSLayoutConstraint? { get }
    weak var rightAnimatableConstraint: NSLayoutConstraint? { get }
    var leftConsrtraintInitialConstant: CGFloat { get }
    var rightConsrtraintInitialConstant: CGFloat { get }
    
    func constraintsToZero(animated: Bool, animationDuration: Double, completion: (() -> Void)?)
    func constraintsToInitValue(animated: Bool, animationDuration: Double, completion: (() -> Void)?)
}

class FoldersMergeAnimator: ConstraintsToZeroAnimator {
    
    private(set) weak var viewForLayout: NSView?
    private(set) weak var leftAnimatableConstraint: NSLayoutConstraint?
    private(set) weak var rightAnimatableConstraint: NSLayoutConstraint?
    private(set) var leftConsrtraintInitialConstant: CGFloat
    private(set) var rightConsrtraintInitialConstant: CGFloat
    
    init(leftFolderAnimatableConsrtraint: NSLayoutConstraint,
         rightFolderAnimatableConsrtraint: NSLayoutConstraint,
         parentView: NSView) {
        
        self.viewForLayout = parentView
        self.leftAnimatableConstraint = leftFolderAnimatableConsrtraint
        self.rightAnimatableConstraint = rightFolderAnimatableConsrtraint
        self.leftConsrtraintInitialConstant = leftFolderAnimatableConsrtraint.constant
        self.rightConsrtraintInitialConstant = rightFolderAnimatableConsrtraint.constant
    }
}

// MARK: - ConstraintsToZeroAnimator DefaultImplementation

extension ConstraintsToZeroAnimator {
    
    func constraintsToZero(animated: Bool = true, animationDuration: Double = 0.5, completion: (() -> Void)?) {
        self.constraintsToZero()
        self.execute(animated: animated, animationDuration: animationDuration, completion: completion)
    }
    
    func constraintsToInitValue(animated: Bool = true, animationDuration: Double = 0.5, completion: (() -> Void)?) {
        self.constraintsToInitValue()
        self.execute(animated: animated, animationDuration: animationDuration, completion: completion)
    }
    
    private func constraintsToZero() {
        self.leftAnimatableConstraint?.constant = 0.0
        self.rightAnimatableConstraint?.constant = 0.0
    }
    
    private func constraintsToInitValue() {
        self.leftAnimatableConstraint?.constant = leftConsrtraintInitialConstant
        self.rightAnimatableConstraint?.constant = rightConsrtraintInitialConstant
    }
    
    private func execute(animated animated: Bool = true, animationDuration: Double = 0.5, completion: (() -> Void)?) {
        if animated {
            NSAnimationContext.runAnimationGroup({ (context) -> Void in
                context.duration = animationDuration
                context.allowsImplicitAnimation = true
                self.viewForLayout?.layoutSubtreeIfNeeded()
                }, completionHandler: completion)
        } else {
            completion?()
        }
    }
}
