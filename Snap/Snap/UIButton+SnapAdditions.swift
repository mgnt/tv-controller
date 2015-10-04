
import UIKit

extension UIButton {
    
    public func tvc_applySnapStyle() {
        titleLabel?.font = UIFont.tvc_snapFont(20.0)
        let buttonImage = UIImage(named: "Button")?.stretchableImageWithLeftCapWidth(15, topCapHeight: 0)
        setBackgroundImage(buttonImage, forState: UIControlState.Normal)
        let pressedImage = UIImage(named: "ButtonPressed")?.stretchableImageWithLeftCapWidth(15, topCapHeight: 0)
        setBackgroundImage(pressedImage, forState: UIControlState.Highlighted)
    }
}
