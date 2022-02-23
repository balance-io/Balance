import UIKit
import SPDiffable
import Constants

class ChooseWalletController: WalletsListController {
    
    private var didSelectWallet: (TokenaryWallet) -> Void
    private let lastSelectedWallet = Flags.last_selected_wallet
    
    init(didSelectWallet: @escaping (TokenaryWallet) -> Void) {
        self.didSelectWallet = didSelectWallet
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = Texts.Wallet.choose_wallet
    }
        
    override func didTapWallet(_ walletModel: TokenaryWallet) {
        self.didSelectWallet(walletModel)
    }
}
