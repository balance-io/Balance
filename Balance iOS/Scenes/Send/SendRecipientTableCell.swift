import UIKit
import NativeUIKit
import SPDiffable
import SparrowKit
import SPSafeSymbols

class SendRecipientTableCell: SPTableViewCell {
    
    let scanButton = Button().do {
        $0.setTitle("Scan")
        $0.setImage(.init(SPSafeSymbol.qrcode))
    }
    
    let recentButton = Button().do {
        $0.setTitle("Recent")
        $0.setImage(.init(SPSafeSymbol.clock.arrowCirclepath))
    }
    
    let pasteButton = Button().do {
        $0.setTitle("Paste")
        $0.setImage(.init(SPSafeSymbol.doc.onDoc))
    }
    
    let buttonBarView = SPView().do {
        $0.layoutMargins = .init(horizontal: NativeLayout.Spaces.default_double, vertical: .zero)
        $0.backgroundColor = .init(light: .init(hex: "F4F9FF"), dark: .tint.secondary)
    }
    
    let textView = SPTextView().do {
        $0.backgroundColor = .clear
        //$0.placeholder = "0x..."
        $0.font = UIFont.preferredFont(forTextStyle: .body).monospaced
        $0.textAlignment = .left
        //$0.contentVerticalAlignment = .top

    }
    
    override func commonInit() {
        super.commonInit()
        selectionStyle = .none
        contentView.addSubviews(buttonBarView, textView)
        buttonBarView.addSubviews([scanButton, recentButton, pasteButton])
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        buttonBarView.frame.setWidth(contentView.frame.width)
        buttonBarView.frame.setHeight(42)
        buttonBarView.frame.setMaxY(contentView.frame.height)
        buttonBarView.frame.origin.x = .zero
        
        textView.frame = .init(
            x: contentView.layoutMargins.left,
            y: contentView.layoutMargins.top,
            width: contentView.layoutWidth,
            height: contentView.frame.height - buttonBarView.frame.height - 4 - contentView.layoutMargins.top
        )
        
        scanButton.sizeToFit()
        scanButton.setYCenter()
        scanButton.frame.origin.x = buttonBarView.layoutMargins.left
        
        recentButton.sizeToFit()
        recentButton.setYCenter()
        recentButton.setXCenter()
        
        pasteButton.sizeToFit()
        pasteButton.setYCenter()
        pasteButton.setMaxXToSuperviewRightMargin()
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        return .init(width: size.width, height: 128)
    }
    
    class Button: SPDimmedButton {
        
        override func commonInit() {
            super.commonInit()
            titleImageInset = 6
            titleLabel?.font = UIFont.preferredFont(forTextStyle: .body, weight: .medium, addPoints: -4)
            applyDefaultAppearance(with: .tintedContent)
        }
    }
}
