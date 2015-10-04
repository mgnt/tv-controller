import Foundation

class BoxView: UIView {
    
    override func drawRect(rect: CGRect) {
        let path = UIBezierPath(ovalInRect: rect)
        UIColor.blackColor().setFill()
        path.fill()
    }
}
