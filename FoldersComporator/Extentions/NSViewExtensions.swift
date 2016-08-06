//
//  NSViewExtensions.swift
//  FoldersComparator
//
//  Created by Evgeniy Gurtovoy on 8/2/16.
//
//

import Cocoa

extension NSView {
    
    // Auto Layout
    func autoPinEdgesToSuperviewEdges() {
        self.autoPinEdgesToSuperviewEdgesWithInsets(NSEdgeInsetsZero)
    }
    
    func autoPinEdgesToSuperviewEdgesWithInsets(insets: NSEdgeInsets) {
        translatesAutoresizingMaskIntoConstraints = false
        if let parrentView = superview {
            parrentView.addConstraints([parrentView.topAnchor.constraintEqualToAnchor(topAnchor, constant: insets.top),
                                        parrentView.leftAnchor.constraintEqualToAnchor(leftAnchor, constant: insets.left),
                                        parrentView.bottomAnchor.constraintEqualToAnchor(bottomAnchor, constant: insets.bottom),
                                        parrentView.rightAnchor.constraintEqualToAnchor(rightAnchor, constant: insets.right)])
        }
    }
    
    // Animation
    func addAnimationForKey<T: CAAnimation>(type: T.Type, _ animation: T -> String?) {
        let anim = T()
        let key = animation(anim)
        layer?.addAnimation(anim, forKey: key)
    }
    
    func removeAnimationForKey(key: String) {
        layer?.removeAnimationForKey(key)
    }

}