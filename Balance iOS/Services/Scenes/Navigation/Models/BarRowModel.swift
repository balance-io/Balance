import UIKit
import SPSafeSymbols

struct BarRowModel {
    
    let id: String
    let title: String
    let image: UIImage
    
    var getController: (() -> UIViewController)
    
    init(id: String, title: String, image: UIImage, getController: @escaping (() -> UIViewController)) {
        self.id = id
        self.title = title
        self.image = image
        self.getController = getController
    }
    
    enum Item: String, CaseIterable {
        
        case wallets
        case nft
        case sent
        case settings
        
        var id: String { return rawValue }
        
        var title: String {
            switch self {
            case .wallets: return Texts.Wallet.wallets
            case .nft: return Texts.NFT.title
            case .sent: return Texts.Wallet.send_title
            case .settings: return Texts.Settings.title
            }
        }
        
        var image: UIImage {
            switch self {
            case .wallets: return UIImage(SPSafeSymbol.mail.stackFill)
            case .nft: return UIImage(SPSafeSymbol.square.stack_3dDownRightFill)
            case .sent: return UIImage(SPSafeSymbol.paperplane.fill)
            case .settings: return UIImage(SPSafeSymbol.gear)
            }
        }
        
        var controller: UIViewController {
            switch self {
            case .wallets: return Controllers.Crypto.accounts
            case .nft: return Controllers.Crypto.NFT.list
            case .sent: return Controllers.Crypto.send
            case .settings: return Controllers.App.Settings.list
            }
        }
    }
}
