import UIKit
import NativeUIKit
import SPDiffable
import SparrowKit
import SPSafeSymbols

class SendAmountTableCell: SPTableViewCell {
    
    
    let textField = SPTextField().do {
        $0.backgroundColor = .clear
        $0.font = UIFont.preferredFont(forTextStyle: .body).monospaced
        $0.textAlignment = .left
    }
    
    let symbol = SPLabel().do {
        $0.textColor = .placeholderText
        $0.font = UIFont.systemFont(ofSize: 16)
        $0.backgroundColor = .clear
        $0.textAlignment = .right
        $0.numberOfLines = 0
    }
    
    override func commonInit() {
        super.commonInit()
        selectionStyle = .none
        contentView.addSubviews(textField)
        contentView.addSubviews(symbol)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let symbolSize = symbol.systemLayoutSizeFitting(CGSize(width: contentView.layoutWidth, height: contentView.layoutHeight))
        symbol.frame = .init(
            x: contentView.layoutWidth - symbolSize.width + NativeLayout.Spaces.default,
            y: contentView.layoutMargins.top,
            width: symbolSize.width,
            height: contentView.layoutHeight
        )
        
        textField.frame = .init(
            x: contentView.layoutMargins.left,
            y: contentView.layoutMargins.top,
            width: contentView.layoutWidth - symbolSize.width - NativeLayout.Spaces.default_half,
            height: contentView.layoutHeight
        )
        
    }
    
}
