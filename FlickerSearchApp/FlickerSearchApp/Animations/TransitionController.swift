//
//  TransitionController
//  FlickerSearchApp
//
//  Created by santosh chaurasia on 20/05/19.
//  Copyright © 2019 santosh104. All rights reserved.
//


import UIKit

class TransitionController: NSObject {
    
    let animator: Animator
    
    
    weak var fromDelegate: AnimatorDelegate?
    weak var toDelegate: AnimatorDelegate?
    
    override init() {
        animator = Animator()
        super.init()
    }
    
}

extension TransitionController: UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        self.animator.isPresenting = true
        self.animator.fromDelegate = fromDelegate
        self.animator.toDelegate = toDelegate
        return self.animator
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        self.animator.isPresenting = false
        let tmp = self.fromDelegate
        self.animator.fromDelegate = self.toDelegate
        self.animator.toDelegate = tmp
        return self.animator
    }
    
    
}

extension TransitionController: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        if operation == .push {
            self.animator.isPresenting = true
            self.animator.fromDelegate = fromDelegate
            self.animator.toDelegate = toDelegate
        } else {
            self.animator.isPresenting = false
            let tmp = self.fromDelegate
            self.animator.fromDelegate = self.toDelegate
            self.animator.toDelegate = tmp
        }
        
        return self.animator
    }
    
}

