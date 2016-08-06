//
//  XRayAnimator.swift
//  FoldersComparator
//
//  Created by Evgeniy Gurtovoy on 8/2/16.
//
//

import Cocoa

class XRayAnimator {
    
    private weak var imageView: NSImageView!
    private weak var parentView: NSView!
    
    init(xRayImageView: NSImageView, parentView: NSView) {
        self.imageView = xRayImageView
        self.parentView = parentView
    }
    
    func animate() {
        self.imageView.animator().alphaValue = 1
        self.imageView.addAnimationForKey(CAKeyframeAnimation.self, { animation in
            animation.keyPath = "position.y"
            animation.values = [0, -(CGRectGetHeight(self.parentView.frame) + CGRectGetHeight(self.imageView.frame))]
            animation.duration = 1
            animation.autoreverses = true
            animation.additive = true
            animation.repeatCount = Float.infinity
            animation.calculationMode = kCAAnimationLinear
            return .xRayPostionAnimationKey
        })
    }
    
    func removeAnimation(completion: (() -> Void)?) {
        let removeAnimationBlock = {
            self.imageView.removeAnimationForKey(.xRayPostionAnimationKey)
            completion?()
        }
        NSAnimationContext.runAnimationGroup({ (context) -> Void in
            context.duration = 0.3
            context.allowsImplicitAnimation = true
            self.imageView.animator().alphaValue = 0
            }, completionHandler: removeAnimationBlock)
    }
}

private typealias AnimationKeys = String
private extension AnimationKeys {
    static let xRayPostionAnimationKey = "xray.position"
}