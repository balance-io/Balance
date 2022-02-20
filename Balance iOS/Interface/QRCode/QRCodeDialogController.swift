import UIKit
import SparrowKit

public class QRCodeDialogController: UIViewController {
    
    public var showCloseButton: Bool = false
    public var allowSwipeDismiss: Bool = true
    public var bounceAnimationEnabled = true
    
    private let dialogView = QRCodeDialogView()
    private let closeButton = QRCodeCloseButton()
    private let backgroundView = QRCodeDialogGradeBlurView()
    
    private let address: String
    
    // MARK: - Init
    
    init(address: String) {
        self.address = address
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
    // MARK: - Lifecycle
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(backgroundView)
        
        // Dialog View
        
        dialogView.alpha = 0
        view.addSubview(dialogView)
        if let image = generateQRCode(from: address) {
            dialogView.imageView.image = image.withRenderingMode(.alwaysTemplate)
            dialogView.imageView.tintColor = .label
        }
        
        // Animator
        
        animator = UIDynamicAnimator(referenceView: view)
        snapBehavior = UISnapBehavior(item: dialogView, snapTo: dialogCenter)
        let panGesture = UIPanGestureRecognizer.init(target: self, action: #selector(self.handleGesture(sender:)))
        panGesture.maximumNumberOfTouches = 1
        dialogView.addGestureRecognizer(panGesture)
        
        closeButton.alpha = 0
        closeButton.addAction(.init(handler: { _ in
            self.dismiss(withDialog: true)
        }), for: .touchUpInside)
        view.addSubview(closeButton)
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        /**
         Special layout call becouse table hasn't valid content size before appear for early ios 12 and lower.
         Happen only if `bounceAnimationEnabled` set to false.
         Related issue on github: https://github.com/ivanvorobei/SPPermissions/issues/262
         */
        if !bounceAnimationEnabled {
            if #available(iOS 13, *) {
                // All good for iOS 13+
            } else {
                delay(0.2) {
                    self.dialogView.layout(in: self.view)
                }
            }
        }
    }
    
    // MARK: - Layout
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        backgroundView.frame = view.bounds
        dialogView.layout(in: view)
        
        if bounceAnimationEnabled {
            snapBehavior.snapPoint = dialogCenter
        } else {
            dialogView.center = dialogCenter
        }
        
        closeButton.frame = .init(side: 35)
        closeButton.frame.origin.y = view.layoutMargins.top + 16
        closeButton.frame.setMaxX(view.frame.width - view.layoutMargins.right)
    }
    
    private var dialogCenter: CGPoint {
        let width = view.frame.width - view.layoutMargins.left - view.layoutMargins.right
        let height = view.frame.height - view.layoutMargins.top - view.layoutMargins.bottom
        return CGPoint(x: view.layoutMargins.left + width / 2, y: view.layoutMargins.top + height / 2)
    }
    
    // MARK: - Helpers
    
    public func present(on controller: UIViewController) {
        animator.removeAllBehaviors()
        dialogView.transform = .identity
        dialogView.center = CGPoint.init(x: dialogCenter.x, y: dialogCenter.y * 1.2)
        modalPresentationStyle = .overCurrentContext
        controller.present(self, animated: false, completion: {
            UIView.animate(withDuration: 0.3, animations: {
                self.backgroundView.setGradeAlpha(0.07)
                self.backgroundView.setBlurRadius(4)
            }, completion: nil)
            UIView.animate(withDuration: 0.3, delay: 0.21, animations: {
                self.dialogView.alpha = 1
                self.closeButton.alpha = 1
            }, completion: nil)
            delay(0.21, closure: { [weak self] in
                guard let self = self else { return }
                if self.bounceAnimationEnabled {
                    self.animator.addBehavior(self.snapBehavior)
                }
            })
        })
    }
    
    @objc func dimissWithDialog() {
        dismiss(withDialog: true)
    }
    
    public func dismiss(withDialog: Bool) {
        if withDialog {
            UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .beginFromCurrentState, animations: {
                self.animator.removeAllBehaviors()
                self.dialogView.transform = CGAffineTransform.init(scaleX: 0.9, y: 0.9)
                self.dialogView.alpha = 0
                self.closeButton.alpha = 0
            }, completion: nil)
        }
        UIView.animate(withDuration: 0.3, animations: {
            self.backgroundView.setGradeAlpha(0)
            self.backgroundView.setBlurRadius(0)
            self.closeButton.alpha = 0
        }, completion: { finished in
            self.dismiss(animated: false, completion: nil)
        })
    }
    
    // MARK: - Animator
    
    private var animator = UIDynamicAnimator()
    private var attachmentBehavior : UIAttachmentBehavior!
    private var gravityBehaviour : UIGravityBehavior!
    private var snapBehavior : UISnapBehavior!
    
    @objc func handleGesture(sender: UIPanGestureRecognizer) {
        
        guard bounceAnimationEnabled, allowSwipeDismiss else {
            return
        }
        
        let location = sender.location(in: view)
        let boxLocation = sender.location(in: dialogView)
        
        switch sender.state {
        case .began:
            animator.removeAllBehaviors()
            let centerOffset = UIOffset(horizontal: boxLocation.x - dialogView.bounds.midX, vertical: boxLocation.y - dialogView.bounds.midY);
            attachmentBehavior = UIAttachmentBehavior(item: dialogView, offsetFromCenter: centerOffset, attachedToAnchor: location)
            attachmentBehavior.frequency = 0
            animator.addBehavior(attachmentBehavior)
        case .changed:
            attachmentBehavior.anchorPoint = location
        case .ended:
            animator.removeBehavior(attachmentBehavior)
            animator.addBehavior(snapBehavior)
            let translation = sender.translation(in: view)
            if translation.y > 100 {
                animator.removeAllBehaviors()
                gravityBehaviour = UIGravityBehavior(items: [dialogView])
                gravityBehaviour.gravityDirection = CGVector.init(dx: 0, dy: 10)
                animator.addBehavior(gravityBehaviour)
                dismiss(withDialog: false)
            }
        default:
            break
        }
    }
    
    func generateQRCode(from string: String) -> UIImage? {
        // Get define string to encode
        let myString = string
        // Get data from the string
        let data = myString.data(using: String.Encoding.ascii)
        // Get a QR CIFilter
        guard let qrFilter = CIFilter(name: "CIQRCodeGenerator") else { return nil }
        // Input the data
        qrFilter.setValue(data, forKey: "inputMessage")
        // Get the output image
        guard let qrImage = qrFilter.outputImage else { return nil }
        // Scale the image
        let transform = CGAffineTransform(scaleX: 20, y: 20)
        let scaledQrImage = qrImage.transformed(by: transform)
        // Invert the colors
        guard let colorInvertFilter = CIFilter(name: "CIColorInvert") else { return nil }
        colorInvertFilter.setValue(scaledQrImage, forKey: "inputImage")
        guard let outputInvertedImage = colorInvertFilter.outputImage else { return nil }
        // Replace the black with transparency
        guard let maskToAlphaFilter = CIFilter(name: "CIMaskToAlpha") else { return nil }
        maskToAlphaFilter.setValue(outputInvertedImage, forKey: "inputImage")
        guard let outputCIImage = maskToAlphaFilter.outputImage else { return nil }
        // Do some processing to get the UIImage
        let context = CIContext()
        guard let cgImage = context.createCGImage(outputCIImage, from: outputCIImage.extent) else { return nil }
        let processedImage = UIImage(cgImage: cgImage)
        return processedImage
    }
}
