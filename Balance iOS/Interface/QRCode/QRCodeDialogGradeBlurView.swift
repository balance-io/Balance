import UIKit

class QRCodeDialogGradeBlurView: UIView {
    
    private var gradeView: UIView = UIView()
    private var blurView: UIView = UIView()
    
    // MARK: - Init
    
    init() {
        super.init(frame: CGRect.zero)
        backgroundColor = .clear
        setGradeColor(UIColor.black)
        setGradeAlpha(0)
        setBlurRadius(0)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func commonInit() {
        blurView = SPPermissionsBlurView()
        layer.masksToBounds = true
        addSubview(gradeView)
        addSubview(blurView)
    }
    
    // MARK: - Helpers
    
    func setGradeColor(_ color: UIColor) {
        gradeView.backgroundColor = UIColor.black
    }
    
    func setGradeAlpha(_ alpha: CGFloat) {
        gradeView.alpha = alpha
    }
    
    func setBlurRadius(_ radius: CGFloat) {
        if let blurView = self.blurView as? SPPermissionsBlurView {
            blurView.setBlurRadius(radius)
        }
    }
    
    // MARK: - Layout
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradeView.frame = bounds
        blurView.frame = bounds
    }
}

public class SPPermissionsBlurView: UIVisualEffectView {
    
    private let blurEffect: UIBlurEffect
    open var blurRadius: CGFloat {
        return blurEffect.value(forKeyPath: "blurRadius") as! CGFloat
    }
    
    public convenience init() {
        self.init(withRadius: 0)
    }
    
    public init(withRadius radius: CGFloat) {
        if #available(iOS 14, *) {
            self.blurEffect = UIBlurEffect(style: .prominent)
            super.init(effect: blurEffect)
            alpha = 0
        } else {
            let customBlurClass: AnyObject.Type = NSClassFromString("_UICustomBlurEffect")!
            let customBlurObject: NSObject.Type = customBlurClass as! NSObject.Type
            blurEffect = customBlurObject.init() as! UIBlurEffect
            blurEffect.setValue(1.0, forKeyPath: "scale")
            blurEffect.setValue(radius, forKeyPath: "blurRadius")
            super.init(effect: radius == 0 ? nil : self.blurEffect)
        }
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open func setBlurRadius(_ radius: CGFloat) {
        if #available(iOS 14, *) {
            alpha = (radius == 0) ? 0 : 1
        } else {
            guard radius != blurRadius else { return }
            blurEffect.setValue(radius, forKeyPath: "blurRadius")
            self.effect = blurEffect
        }
    }
}
