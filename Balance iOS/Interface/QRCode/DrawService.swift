import UIKit

#if os(iOS)

enum DrawService {
    
    public static func drawClose(frame targetFrame: CGRect = CGRect(x: 0, y: 0, width: 28, height: 28), resizing: ResizingBehavior = .aspectFit, background: UIColor = UIColor(red: 0.937, green: 0.937, blue: 0.941, alpha: 1.000), element: UIColor = UIColor(red: 0.518, green: 0.518, blue: 0.533, alpha: 1.000)) {
        
        let context = UIGraphicsGetCurrentContext()!
        
        
        context.saveGState()
        let resizedFrame: CGRect = resizing.apply(rect: CGRect(x: 0, y: 0, width: 28, height: 28), target: targetFrame)
        context.translateBy(x: resizedFrame.minX, y: resizedFrame.minY)
        context.scaleBy(x: resizedFrame.width / 28, y: resizedFrame.height / 28)
        
        
        //// Rect Drawing
        let rectPath = UIBezierPath()
        rectPath.move(to: CGPoint(x: 14, y: 28))
        rectPath.addCurve(to: CGPoint(x: 0, y: 14), controlPoint1: CGPoint(x: 6.32, y: 28), controlPoint2: CGPoint(x: 0, y: 21.66))
        rectPath.addCurve(to: CGPoint(x: 13.99, y: 0), controlPoint1: CGPoint(x: 0, y: 6.34), controlPoint2: CGPoint(x: 6.32, y: 0))
        rectPath.addCurve(to: CGPoint(x: 28, y: 14), controlPoint1: CGPoint(x: 21.65, y: 0), controlPoint2: CGPoint(x: 28, y: 6.34))
        rectPath.addCurve(to: CGPoint(x: 14, y: 28), controlPoint1: CGPoint(x: 28, y: 21.66), controlPoint2: CGPoint(x: 21.66, y: 28))
        rectPath.close()
        background.setFill()
        rectPath.fill()
        
        
        //// Icon Drawing
        let iconPath = UIBezierPath()
        iconPath.move(to: CGPoint(x: 8.88, y: 20.03))
        iconPath.addCurve(to: CGPoint(x: 9.55, y: 19.75), controlPoint1: CGPoint(x: 9.14, y: 20.03), controlPoint2: CGPoint(x: 9.37, y: 19.93))
        iconPath.addLine(to: CGPoint(x: 13.99, y: 15.3))
        iconPath.addLine(to: CGPoint(x: 18.44, y: 19.75))
        iconPath.addCurve(to: CGPoint(x: 19.11, y: 20.03), controlPoint1: CGPoint(x: 18.61, y: 19.92), controlPoint2: CGPoint(x: 18.84, y: 20.03))
        iconPath.addCurve(to: CGPoint(x: 20.03, y: 19.12), controlPoint1: CGPoint(x: 19.63, y: 20.03), controlPoint2: CGPoint(x: 20.03, y: 19.63))
        iconPath.addCurve(to: CGPoint(x: 19.75, y: 18.45), controlPoint1: CGPoint(x: 20.03, y: 18.86), controlPoint2: CGPoint(x: 19.93, y: 18.63))
        iconPath.addLine(to: CGPoint(x: 15.3, y: 14))
        iconPath.addLine(to: CGPoint(x: 19.75, y: 9.53))
        iconPath.addCurve(to: CGPoint(x: 20.04, y: 8.88), controlPoint1: CGPoint(x: 19.96, y: 9.34), controlPoint2: CGPoint(x: 20.04, y: 9.13))
        iconPath.addCurve(to: CGPoint(x: 19.11, y: 7.97), controlPoint1: CGPoint(x: 20.04, y: 8.37), controlPoint2: CGPoint(x: 19.63, y: 7.97))
        iconPath.addCurve(to: CGPoint(x: 18.47, y: 8.26), controlPoint1: CGPoint(x: 18.87, y: 7.97), controlPoint2: CGPoint(x: 18.66, y: 8.05))
        iconPath.addLine(to: CGPoint(x: 13.99, y: 12.72))
        iconPath.addLine(to: CGPoint(x: 9.53, y: 8.26))
        iconPath.addCurve(to: CGPoint(x: 8.88, y: 7.98), controlPoint1: CGPoint(x: 9.35, y: 8.08), controlPoint2: CGPoint(x: 9.14, y: 7.98))
        iconPath.addCurve(to: CGPoint(x: 7.96, y: 8.89), controlPoint1: CGPoint(x: 8.36, y: 7.98), controlPoint2: CGPoint(x: 7.96, y: 8.37))
        iconPath.addCurve(to: CGPoint(x: 8.24, y: 9.53), controlPoint1: CGPoint(x: 7.96, y: 9.14), controlPoint2: CGPoint(x: 8.05, y: 9.37))
        iconPath.addLine(to: CGPoint(x: 12.69, y: 14))
        iconPath.addLine(to: CGPoint(x: 8.24, y: 18.47))
        iconPath.addCurve(to: CGPoint(x: 7.96, y: 19.12), controlPoint1: CGPoint(x: 8.05, y: 18.65), controlPoint2: CGPoint(x: 7.96, y: 18.86))
        iconPath.addCurve(to: CGPoint(x: 8.88, y: 20.03), controlPoint1: CGPoint(x: 7.96, y: 19.63), controlPoint2: CGPoint(x: 8.36, y: 20.03))
        iconPath.close()
        element.setFill()
        iconPath.fill()
        
        context.restoreGState()
        
    }
    
    @objc(StyleKitNameResizingBehavior)
    public enum ResizingBehavior: Int {
        case aspectFit /// The content is proportionally resized to fit into the target rectangle.
        case aspectFill /// The content is proportionally resized to completely fill the target rectangle.
        case stretch /// The content is stretched to match the entire target rectangle.
        case center /// The content is centered in the target rectangle, but it is NOT resized.
        
        public func apply(rect: CGRect, target: CGRect) -> CGRect {
            if rect == target || target == CGRect.zero {
                return rect
            }
            
            var scales = CGSize.zero
            scales.width = abs(target.width / rect.width)
            scales.height = abs(target.height / rect.height)
            
            switch self {
            case .aspectFit:
                scales.width = min(scales.width, scales.height)
                scales.height = scales.width
            case .aspectFill:
                scales.width = max(scales.width, scales.height)
                scales.height = scales.width
            case .stretch:
                break
            case .center:
                scales.width = 1
                scales.height = 1
            }
            
            var result = rect.standardized
            result.size.width *= scales.width
            result.size.height *= scales.height
            result.origin.x = target.minX + (target.width - result.width) / 2
            result.origin.y = target.minY + (target.height - result.height) / 2
            return result
        }
    }
}

#endif
