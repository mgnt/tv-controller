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
    
    optional func requestHeartbeat(requestTime: CFTimeInterval)
}

let kTouchViewControllerTapItemCount = 9

class TouchViewController: UIViewController, TapViewDelegate {
    
    var delegate: TouchViewControllerDelegate?
    
    @IBOutlet weak var label: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up the view colors
        for (var tapViewTag = 1; tapViewTag < (kTouchViewControllerTapItemCount + 1); tapViewTag++) {
            let tapView = view.viewWithTag(tapViewTag)
            assert(tapView!.isKindOfClass(TapView))
            tapView!.backgroundColor = UIColor(hue: CGFloat(tapViewTag)/CGFloat(kTouchViewControllerTapItemCount), saturation: 0.75, brightness: 0.75, alpha: 1.0)
        }
        
        // having this going at the time the iOS device is first connecting causes the initial connection to fail
        // TODO: start when game starts (after connection is established)
        NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "requestHeartbeat", userInfo: nil, repeats: true)
    }
    
    func requestHeartbeat() {
        delegate?.requestHeartbeat?(CACurrentMediaTime())
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
    
    func receiveHeartbeat(requestTime: CFTimeInterval) {
        let delay = (CACurrentMediaTime() - requestTime) * 1000.0
        //print("delay = \(delay)")
        label.text = "\(delay) ms"
    }
    
    // MARK: Tap view delegate callbacks
    
    func tapViewLocalTouchDown(tapView: TapView!) {
        assert(tapView.tag != 0)
        assert(tapView.tag <= kTouchViewControllerTapItemCount)
        delegate?.touchViewController?(self, localTouchDownOnItem: UInt(tapView.tag-1))
        
        
        // test
        //delegate?.requestHeartbeat?(CACurrentMediaTime())
    }
    
    func tapViewLocalTouchUp(tapView: TapView!) {
        assert(tapView.tag != 0)
        assert(tapView.tag <= kTouchViewControllerTapItemCount)
        delegate?.touchViewController?(self, localTouchUpOnItem: UInt(tapView.tag-1))
    }
}
