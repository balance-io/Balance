import UIKit
import SparrowKit
import SPDiffable
import NativeUIKit
import SPSafeSymbols
import SafariServices
import Constants
import SPAlert

class HomeController: NativeHeaderTableController {
    
    // MARK: - Data
    
    private var wallets: [TokenaryWallet] { WalletsManager.shared.wallets }
    
    // MARK: - Views
    
    public let headerView = HomeHeaderController()
    
    // MARK: - Init
    
    public init() {
        super.init(style: .insetGrouped, headerView: headerView)
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Lifecycle
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = Texts.App.name_short
        navigationItem.rightBarButtonItem = .init(barButtonSystemItem: .add, target: self, action: #selector(showAddWallet))
        tableView.register(WalletTableViewCell.self)
        tableView.register(NativeLeftButtonTableViewCell.self)
        tableView.register(NativeEmptyTableViewCell.self)
        tableView.register(SafariTableViewCell.self)
        configureDiffable(
            sections: content,
            cellProviders: [.button, .wallet, .empty] + [
                .init(clouser: { tableView, indexPath, item in
                    if item.id == Item.safariSteps.id {
                        let cell = tableView.dequeueReusableCell(withClass: SafariTableViewCell.self, for: indexPath)
                        cell.closeButton.addAction(.init(handler: { _ in
                            Flags.show_safari_extension_advice = false
                            self.diffableDataSource?.set(self.content, animated: true)
                        }), for: .touchUpInside)
                        cell.runButton.addAction(.init(handler: { _ in
                            guard let url = URL(string: Constants.instructions) else { return }
                            UIApplication.shared.open(url)
                        }), for: .touchUpInside)
                        return cell
                    }
                    return nil
                })
            ],
            headerFooterProviders: [.largeHeader]
        )
        NotificationCenter.default.addObserver(forName: .walletsUpdated, object: nil, queue: nil) { _ in
            self.diffableDataSource?.set(self.content, animated: true)
        }
        
        setSpaceBetweenHeaderAndCells(NativeLayout.Spaces.default)
        
        if wallets.isEmpty && !UserSettings.added_default_wallet {
            // Create default wallet only once
            let walletsManager = WalletsManager.shared
            do {
                let walletModel = try walletsManager.createWallet()
                walletModel.walletName = "Default Wallet"
                UserSettings.added_default_wallet = true
            } catch {
                SPAlert.present(message: "Can't create default wallet. Error: \(error.localizedDescription)", haptic: .error, completion: nil)
            }
        }
    }
    
    // MARK: - Actions
    
    @objc private func showAddWallet() {
        Presenter.Crypto.showImportWallet(on: self)
    }
    
    // MARK: - Diffable
    
    internal enum Section: String {
        
        case safari
        case accounts
        case changePassword
        
        var id: String { rawValue + "_section" }
    }
    
    enum Item: String {
        
        case safariSteps
        case emptyAccounts
        
        var id: String { return rawValue }
    }
    
    private var content: [SPDiffableSection] {
        
        let walletItems: [SPDiffableItem] = {
            if wallets.isEmpty {
                return [
                    NativeEmptyRowItem(
                        id: Item.emptyAccounts.id,
                        verticalMargins: .large,
                        text: Texts.Wallet.empty_title,
                        detail: Texts.Wallet.empty_description
                    )
                ]
            } else {
                var items: [SPDiffableItem] = wallets.prefix(4).map({ walletModel in
                    SPDiffableWrapperItem(id: walletModel.id, model: walletModel) { item, indexPath in
                        guard let navigationController = self.navigationController else { return }
                        Presenter.Crypto.showWalletDetail(walletModel, on: navigationController)
                    }
                })
                if wallets.count > 2 {
                    items.append(
                        NativeDiffableLeftButton(
                            text: Texts.Wallet.open_all_wallets,
                            textColor: .systemBlue,
                            detail: "Total \(wallets.count) wallets",
                            detailColor: .gray,
                            icon: nil,
                            accessoryType: .disclosureIndicator,
                            action: { item, indexPath in
                                guard let navigationController = self.navigationController else { return }
                                Presenter.Crypto.showWallets(on: navigationController)
                            }
                        )
                    )
                }
                return items
            }
        }()
        
        var sections: [SPDiffableSection] = []
        
        if Flags.show_safari_extension_advice {
            sections.append(
                .init(
                    id: Section.safari.id,
                    header: SPDiffableTextHeaderFooter(text: Texts.Wallet.SafariExtension.propose_header),
                    footer: SPDiffableTextHeaderFooter(text: Texts.Wallet.SafariExtension.propose_footer),
                    items: [.init(id: Item.safariSteps.id)]
                )
            )
        }
        
        sections += [
            .init(
                id: Section.accounts.id,
                header: NativeLargeHeaderItem(
                    title: Texts.Wallet.wallets,
                    actionTitle: nil,
                    action: nil
                ),
                footer: nil,
                items: walletItems
            )
        ]
        
        return sections
    }
}
