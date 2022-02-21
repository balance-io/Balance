// The MIT License (MIT)
// Copyright © 2021 Ivan Vorobei (hello@ivanvorobei.by)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import UIKit
import SPDiffable
import SparrowKit
import NativeUIKit
import BlockiesSwift

extension SPDiffableCollectionDataSource.HeaderFooterProvider {
    
    public static var wallet: SPDiffableCollectionDataSource.HeaderFooterProvider  {
        return SPDiffableCollectionDataSource.HeaderFooterProvider.init { collectionView, kind, indexPath, item in
            guard let walletModel = (item as? SPDiffableWrapperItem)?.model as? TokenaryWallet else { return nil }
            let view = collectionView.dequeueReusableSupplementaryView(withCalss: WalletHeaderCollectionView.self, kind: kind, for: indexPath)
            view.configureWithWallet(walletModel)
            return view
        }
    }
}

open class WalletHeaderCollectionView: SPCollectionReusableView {
    
    let avatarView = NativeAvatarView().do {
        $0.isEditable = false
    }
    
    let titleLabel = SPLabel().do {
        $0.font = UIFont.preferredFont(forTextStyle: .title3, weight: .semibold).rounded
        $0.textColor = .label
    }
    
    let addressLabel = SPLabel().do {
        $0.font = UIFont.preferredFont(forTextStyle: .body, weight: .regular, addPoints: -2).monospaced
        $0.textColor = .secondaryLabel
    }
    
    open override func commonInit() {
        super.commonInit()
        addSubviews(avatarView, titleLabel, addressLabel)
    }
    
    open override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
        addressLabel.text = nil
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        avatarView.frame = .init(side: 35)
        avatarView.frame.origin.x = layoutMargins.left
        let leftSpace: CGFloat = NativeLayout.Spaces.default_less
        let labelsWidth = frame.width - avatarView.frame.maxX - layoutMargins.right - leftSpace
        titleLabel.layoutDynamicHeight(x: avatarView.frame.maxX + leftSpace, y: layoutMargins.top, width: layoutWidth)
        addressLabel.layoutDynamicHeight(x: titleLabel.frame.origin.x, y: titleLabel.frame.maxY + 2, width: labelsWidth)
        avatarView.setYCenter()
        
        let allHeight = titleLabel.frame.height + addressLabel.frame.height + 2
        titleLabel.frame.origin.y = (frame.height - allHeight) / 2
        addressLabel.frame.origin.y = titleLabel.frame.maxY + 2
    }
    
    func configureWithWallet(_ walletModel: TokenaryWallet) {
        
        let addAddress = {
            var formattedAddress = walletModel.ethereumAddress ?? .space
            formattedAddress.insert("\n", at: formattedAddress.index(formattedAddress.startIndex, offsetBy: (formattedAddress.count / 2)))
            
            self.addressLabel.text = formattedAddress
            self.addressLabel.minimumScaleFactor = 0.1
            self.addressLabel.numberOfLines = 2
            self.addressLabel.adjustsFontSizeToFitWidth = true
            
            let attrString = WalletController.formatETHAddress(
                formattedAddress,
                textColor: .secondaryLabel,
                normalFont: UIFont.preferredFont(forTextStyle: .body, weight: .regular, addPoints: -2).monospaced,
                higlightFont: UIFont.preferredFont(forTextStyle: .body, weight: .bold, addPoints: -2).monospaced
            )
            self.addressLabel.attributedText = attrString
        }
        
        let addName = {
            if let name = walletModel.walletName?.trim, !name.isEmptyContent {
                self.titleLabel.text = name
                self.titleLabel.textColor = .label
            } else {
                self.titleLabel.text = Texts.Wallet.no_name
                self.titleLabel.textColor = .secondaryLabel
            }
        }
        
        switch WalletStyle.current {
        case .nameAndAddress:
            addAddress()
            addName()
        case .onlyAddress:
            addAddress()
        case .onlyName:
            addName()
        }
        
        if let adress = walletModel.ethereumAddress {
            if let image = Blockies(seed: adress.lowercased()).createImage() {
                self.avatarView.avatarAppearance = .avatar(image)
            }
        }
        
        self.layoutSubviews()
    }
}
