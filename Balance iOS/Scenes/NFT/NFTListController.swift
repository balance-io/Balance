import UIKit
import SparrowKit
import NativeUIKit
import SPSafeSymbols
import SPDiffable
import SPIndicator
import SafariServices

class NFTListController: SPDiffableCollectionController, UICollectionViewDelegateFlowLayout {
    
    let placeholderView = NativePlaceholderView(
        icon: .init(SPSafeSymbol.square.stack_3dDownRightFill, font: .systemFont(ofSize: 48, weight: .semibold)),
        title: "No any NFT",
        subtitle: "Tap here for force reload"
    )
    
    internal let layout = UICollectionViewFlowLayout()
    
    struct Data {
        
        let wallet: TokenaryWallet
        let nfts: [NFTModel]
    }
    
    private var data: [Data] = []
    
    init() {
        super.init(collectionViewLayout: UICollectionViewFlowLayout())
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.backgroundColor = .systemGroupedBackground
        navigationItem.title = Texts.NFT.title
        
        layout.sectionInsetReference = .fromLayoutMargins
        layout.minimumLineSpacing = 8
        layout.minimumInteritemSpacing = 8
        layout.scrollDirection = .vertical
        collectionView.setCollectionViewLayout(layout, animated: false)
        
        placeholderView.addAction(UIAction.init(handler: { _ in
            self.placeholderView.setVisible(false, animated: true)
            self.updateData()
            SPIndicator.present(title: "Updating...", preset: .done)
        }), for: .touchUpInside)
        collectionView.addSubview(placeholderView)
        collectionView.alwaysBounceVertical = true
        collectionView.register(NFTCollectionViewCell.self)
        collectionView.preservesSuperviewLayoutMargins = true
        collectionView.register(WalletHeaderCollectionView.self, kind: UICollectionView.elementKindSectionHeader)
        
        configureDiffable(
            sections: content,
            cellProviders: [
                .init(clouser: { collectionView, indexPath, item in
                    guard let nftModel = (item as? SPDiffableWrapperItem)?.model as? NFTModel else { return nil }
                    let cell = collectionView.dequeueReusableCell(withClass: NFTCollectionViewCell.self, for: indexPath)
                    cell.setNFT(nftModel)
                    return cell
                })
            ],
            headerFooterProviders: [.wallet],
            headerAsFirstCell: false
        )
        
        collectionView.delegate = self
        
        // Get Data
        updateData()
        
        NotificationCenter.default.addObserver(forName: .walletsUpdated, object: nil, queue: nil) { _ in
            self.diffableDataSource?.set(self.content, animated: true, completion: nil)
        }
    }
    
    @objc func updateData() {
        self.data = []
        
        let wallets = WalletsManager.shared.wallets
        for wallet in wallets {
            wallet.getNFT(completion: { models in
                if !models.isEmpty {
                    self.data.append(Data(wallet: wallet, nfts: models))
                    self.diffableDataSource?.set(self.content, animated: true, completion: {
                        self.placeholderView.setVisible(self.data.isEmpty, animated: true)
                    })
                }
            })
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        placeholderView.layoutCenter()
    }
    
    // MARK: - Diffable
    
    internal var content: [SPDiffableSection] {
        var sections: [SPDiffableSection] = []
        for dataItem in data {
            if let address = dataItem.wallet.ethereumAddress {
                let section = SPDiffableSection(
                    id: address,
                    header: SPDiffableWrapperItem(id: address + "header", model: dataItem.wallet),
                    footer: nil,
                    items: dataItem.nfts.map({ nft in
                        return SPDiffableWrapperItem(id: nft.id + address, model: nft, action: nil)
                    })
                )
                sections.append(section)
            }
        }
        return sections.filter({ !$0.items.isEmpty })
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let model = diffableDataSource?.getItem(indexPath: indexPath) as? SPDiffableWrapperItem else { return }
        guard let nftModel = model.model as? NFTModel else { return }
        let controller = SFSafariViewController(url: nftModel.permalink)
        self.present(controller, animated: true, completion: nil)
    }
    
    // MARK: - UICollectionViewFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let items = Int(collectionView.layoutWidth / 170)
        let spaces = CGFloat(items - 1) * layout.minimumInteritemSpacing
        let forItem = (collectionView.layoutWidth - spaces) / CGFloat(items)
        return CGSize(width: forItem - 1, height: forItem + 35)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return .init(width: collectionView.frame.width, height: 100)
    }
}
