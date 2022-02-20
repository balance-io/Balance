import UIKit
import NativeUIKit
import SPSafeSymbols
import SPIndicator

class AddressDiffableItem: NativeDiffableLeftButton {
    
    init(_ walletModel: TokenaryWallet) {
        let address =  walletModel.ethereumAddress ?? .space
        var formattedAddress = address
        formattedAddress.insert("\n", at: formattedAddress.index(formattedAddress.startIndex, offsetBy: (formattedAddress.count / 2)))
        super.init(id: nil, text: formattedAddress, textColor: .tint, detail: nil, icon: .init(SPSafeSymbol.doc.onDoc), accessoryType: .none, higlightStyle: .content) { item, indexPath in
            UIPasteboard.general.string = walletModel.ethereumAddress
            SPIndicator.present(title: Texts.Wallet.address_copied, preset: .done)
        }
    }
}
