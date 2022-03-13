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
                items: WalletsManager.getRecentAddress().map({ data in
                    let formateedAddress = String(data.address.prefix(6)) + "···" + String(data.address.suffix(4))
                    return SPDiffableTableRow(
                        id: data.address + "\(data.amount)" + "\(Int.random(in: 1...10000000))",
                        text: formateedAddress,
                        detail: String(data.amount) + .space + data.chain.symbol,
                        action: { item, indexPath in
                            self.didSelectAddress(data.address, self)
                        }
                    )
                })
            )
        ]
    }
}
