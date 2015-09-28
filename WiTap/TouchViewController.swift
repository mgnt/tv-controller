//
//  TouchViewController.swift
//  WiTap
//
//  Swift version of TapViewController
//
//

import Foundation
import UIKit

@objc protocol TouchViewControllerDelegate {
    
    // Called when the user touches down or up on one of the tap items.
    optional func touchViewController(controller: TouchViewController!, localTouchDownOnItem tapItemIndex: UInt)
    optional func touchViewController(controller: TouchViewController!, localTouchUpOnItem tapItemIndex: UInt)
    
    optional func touchViewControllerDidClose(controller: TouchViewController!)
}

class TouchViewController: UIViewController, TapViewDelegate {
    
    var delegate: TouchViewControllerDelegate?
    
    let kTouchViewControllerTapItemCount = 9
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up the view colors
        for (var tapViewTag = 1; tapViewTag < (kTouchViewControllerTapItemCount + 1); tapViewTag++) {
            let tapView = view.viewWithTag(tapViewTag)
            assert(tapView!.isKindOfClass(TapView))
            tapView!.backgroundColor = UIColor(hue: CGFloat(tapViewTag)/CGFloat(kTouchViewControllerTapItemCount), saturation: 0.75, brightness: 0.75, alpha: 1.0)
        }
    }
    
    @IBAction func closeButtonAction(sender: UIButton) {
        delegate?.touchViewControllerDidClose?(self)
    }
    
    // MARK: TouchViewController Public API
    
    func remoteTouchDownOnItem(tapItemIndex: UInt) {
        
        // TODO: if this assert fails, we'll crash. but actually, we should just ignore the message
        assert(Int(tapItemIndex) < kTouchViewControllerTapItemCount)
        
        if isViewLoaded() {
            let tapView = view.viewWithTag(Int(tapItemIndex)+1) as! TapView
            tapView.remoteTouch = true
        }
    }
    
    func remoteTouchUpOnItem(tapItemIndex: UInt) {
        
        // TODO: if this assert fails, we'll crash. but actually, we should just ignore the message
        assert(Int(tapItemIndex) < kTouchViewControllerTapItemCount)
        
        if isViewLoaded() {
            let tapView = view.viewWithTag(Int(tapItemIndex)+1) as! TapView
            tapView.remoteTouch = false
        }
    }
    
    func resetTouches() {
        for (var tag = 1; tag <= kTouchViewControllerTapItemCount; tag++) {
            let tapView = view.viewWithTag(tag) as! TapView
            assert(tapView.isKindOfClass(TapView))
            tapView.resetTouches()
        }
    }
    
    // MARK: Tap view delegate callbacks
    
    func tapViewLocalTouchDown(tapView: TapView!) {
        assert(tapView.tag != 0)
        assert(tapView.tag <= kTouchViewControllerTapItemCount)
        delegate?.touchViewController?(self, localTouchDownOnItem: UInt(tapView.tag-1))
    }
    
    func tapViewLocalTouchUp(tapView: TapView!) {
        assert(tapView.tag != 0)
        assert(tapView.tag <= kTouchViewControllerTapItemCount)
        delegate?.touchViewController?(self, localTouchUpOnItem: UInt(tapView.tag-1))
    }
}
