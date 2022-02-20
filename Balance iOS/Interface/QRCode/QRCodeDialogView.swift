import UIKit
import SparrowKit

class QRCodeDialogView: UIView {
    
    let imageView = SPImageView().do {
        $0.contentMode = .scaleAspectFit
    }
    
    init() {
        super.init(frame: .zero)
        
        backgroundColor = UIColor.systemBackground
        layer.cornerRadius = 15
        layer.anchorPoint = CGPoint.init(x: 0.5, y: 0.5)
        insetsLayoutMarginsFromSafeArea = false
        
        layoutMargins = .init(side: 18)
        
        addSubview(imageView)
        imageView.setEqualSuperviewMarginsWithAutoLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func layout(in view: UIView) {
        var width = view.bounds.width - 20 * 2
        if view.bounds.width > view.bounds.height * 1.35 {
            if width > 550 { width = 550 }
        } else {
            if width > 380 { width = 380 }
        }
        bounds = CGRect.init(x: 0, y: 0, width: width, height: width)
        
        // Shadow
        
        let shadowPath = UIBezierPath.init(roundedRect: CGRect.init(x: 0, y: 9, width: bounds.width, height: bounds.height), cornerRadius: layer.cornerRadius)
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize.zero
        layer.shadowOpacity = Float(0.07)
        layer.shadowRadius = layer.cornerRadius
        layer.masksToBounds = false
        layer.shadowPath = shadowPath.cgPath
    }
}
