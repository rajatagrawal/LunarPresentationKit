//
//  LNSideSheetPresentationController.swift
//  LunarPresentationKit
//
//  Created by Rajat Agrawal on 9/14/19.
//  Copyright © 2019 Rajat Agrawal. All rights reserved.
//

import UIKit
import CocoaLumberjack

public class LNSideSheetPresentationController: LNPresentationController {
    public override init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?) {
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
        animator = LNSideSheetAnimator()
    }
    
    public override func initializeDismissalPanGesture() {
        let panGesture = UIScreenEdgePanGestureRecognizer()
        panGesture.edges = .left
        presentedViewController.view.addGestureRecognizer(panGesture)
        dismissalViewPanGesture = panGesture
        super.initializeDismissalPanGesture()
    }
    
    @objc public override func dismissalPanGestureListener(panGesture : UIScreenEdgePanGestureRecognizer) {
        DDLogVerbose("presentation controller : dismissal pan gesture listener")
        guard let containerView = containerView, let window = containerView.window else {
            DDLogWarn("dismissal container view or window not present")
            return
        }
        let locationInContainer = panGesture.location(in: containerView).x
        let percentage = locationInContainer/window.bounds.size.width
        
        DDLogVerbose("location in container \(locationInContainer) percentage is \(percentage)")
        DDLogVerbose("dismissal pan gesture state is \(panGesture.state.rawValue)")
        if (panGesture.state == .began) {
            presentedViewController.dismiss(animated: true, completion: nil)
        }
        if (panGesture.state == .changed) {
            DDLogDebug("Dismissal percentage is \(percentage)")
            dismissalInteractor?.update(percentage)
        } else if (panGesture.state == .ended) {
            if (percentage >= 0.3) {
                DDLogDebug("pan gesture finishing dismissal at percentage \(percentage)")
                dismissalInteractor?.finish()
            } else {
                DDLogDebug("pan gesture cancelling dismissal at percentage \(percentage)")
                dismissalInteractor?.cancel()
            }
        } else {
            DDLogDebug("dismissal pan gesture came in the else with state \(panGesture.state.rawValue)")
        }
    }
    @objc public override func presentationPanGestureListener(panGesture : UIScreenEdgePanGestureRecognizer) {
        guard let containerView = containerView, let window = containerView.window else {
            return
        }
        let location = panGesture.location(in: nil).x
        var percentage = location/window.bounds.size.width
        if (panGesture.edges == .right) {
            percentage = 1.0 - percentage
        }
        
        if (panGesture.state == .changed) {
            DDLogDebug("presentation percentage is \(percentage)")
            presentationInteractor?.update(percentage)
        } else if (panGesture.state == .ended) {
            if (percentage >= 0.3) {
                DDLogDebug("pan gesture finishing presentation at percentage \(percentage)")
                presentationInteractor?.finish()
            } else {
                DDLogDebug("pan gesture cancelling presentation at percentage \(percentage)")
                presentationInteractor?.cancel()
            }
        }
    }
    
    public override var frameOfPresentedViewInContainerView: CGRect {
        return containerView?.frame ?? .zero
    }
}
