//
//  Transition.swift
//  FullscreenDemo
//
//  Created by dd on 2018/12/10.
//  Copyright © 2018年 dd. All rights reserved.
//

import UIKit

class Transition: NSObject{
    
    enum TransitionType {
        case present
        case dismiss
    }
    private let ScreenWidth = UIScreen.main.bounds.size.width
    private let ScreenHeight = UIScreen.main.bounds.size.height
    
    static private let transition = Transition()
    static private var duration: Double = 1
    static private var tran: TransitionType = .present
    
    static func presentWithAnimate(fromVC: UIViewController,
                                   toVC: UIViewController,
                                   duration: Double = 0.5){
        Transition.duration = duration
        toVC.transitioningDelegate = Transition.transition
        fromVC.present(toVC, animated: true) { }
    }
}

extension Transition: UIViewControllerAnimatedTransitioning{
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return Transition.duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        switch Transition.tran {
        case .present:
            presentTransition(transitionContext: transitionContext)
        case .dismiss:
            dismissTransition(transitionContext: transitionContext)
        }
    }
}

extension Transition: UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        Transition.tran = .present
        return Transition()
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        Transition.tran = .dismiss
        return Transition()
    }
}

extension Transition{
    
    private func presentTransition(transitionContext: UIViewControllerContextTransitioning){
        let toVC = transitionContext.viewController(forKey: .to)
        let fromVC = transitionContext.viewController(forKey: .from)
        
        guard let fromView = fromVC?.view,
            let toView = toVC?.view else {
                return
        }
        
        transitionContext.containerView.addSubview(toView)
        rotatePresent(fromView: fromView,
                     toView: toView,
                     transitionContext: transitionContext)
    }
    
    private func dismissTransition(transitionContext: UIViewControllerContextTransitioning){
        let toVC = transitionContext.viewController(forKey: .to)
        let fromVC = transitionContext.viewController(forKey: .from)
        
        guard let fromView = fromVC?.view,
            let toView = toVC?.view else {
                return
        }
        rotateDismiss(fromView: fromView,toView: toView,transitionContext: transitionContext)
    }
    
    private func rotatePresent(fromView: UIView, toView: UIView, transitionContext: UIViewControllerContextTransitioning){
        
        
        toView.alpha = 0.0
        UIView.animate(withDuration: Transition.duration, animations: {
            toView.alpha = 1.0
        }) { (_) in
            toView.alpha = 1.0
            transitionContext.completeTransition(true)
        }
    }
    
    private func rotateDismiss(fromView: UIView,
                               toView: UIView,
                               transitionContext: UIViewControllerContextTransitioning){
        transitionContext.containerView.insertSubview(toView, belowSubview: fromView)
       
        UIView.animate(withDuration: Transition.duration, animations: {
            
            fromView.alpha = 0
        }) { (_) in
            fromView.alpha = 0
            transitionContext.completeTransition(true)
        }
    }
}
