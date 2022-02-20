import UIKit

class QRCodeCloseButton: UIButton {
    
    let iconView = CloseIconView()
    
    // MARK: - Init
    
    init() {
        super.init(frame: .zero)
        backgroundColor = .clear
        iconView.backgroundColor = .clear
        iconView.isUserInteractionEnabled = false
        addSubview(iconView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Layout
    
    override func layoutSubviews() {
        super.layoutSubviews()
        iconView.frame = bounds
    }
    
    // MARK: - CloseIconView
    
    class CloseIconView: UIView {
        
        var elementColor: UIColor = UIColor.tintColor
        var areaColor: UIColor = UIColor.systemBackground
        
        override func draw(_ rect: CGRect) {
            DrawService.drawClose(frame: rect, resizing: .aspectFit, background: areaColor, element: elementColor)
        }
    }
}
