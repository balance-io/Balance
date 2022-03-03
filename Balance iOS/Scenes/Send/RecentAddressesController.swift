import UIKit
import SPDiffable

class RecentAddressesController: SPDiffableTableController {

    private let didSelectAddress: (String, RecentAddressesController)->()
    
    // MARK: - Init
    
    init(didSelectAddress: @escaping (String, RecentAddressesController)->()) {
        self.didSelectAddress = didSelectAddress
        super.init(style: .insetGrouped)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.setNavigationBarHidden(true, animated: false)
        view.backgroundColor = .systemGroupedBackground
        
        configureDiffable(
            sections: content,
            cellProviders: SPDiffableTableDataSource.CellProvider.default
        )
    }
    
    // MARK: - Diffable
    
    internal enum Section: String {
        
        case addresses
        
        var id: String { rawValue }
    }
    
    internal var content: [SPDiffableSection] {
        return [
            .init(
                id: Section.addresses.id,
                header: nil,
                footer: nil,
                items: WalletsManager.recentAddresses.map({ address in
                    let formateedAddress = String(address.prefix(6)) + "···" + String(address.suffix(4))
                    return SPDiffableTableRow(
                        text: formateedAddress,
                        detail: "\(Int.random(in: 1...9)).\(Int.random(in: 1...999)) ETH",
                        action: { item, indexPath in
                            self.didSelectAddress(address, self)
                        }
                    )
                })
            )
        ]
    }
}
