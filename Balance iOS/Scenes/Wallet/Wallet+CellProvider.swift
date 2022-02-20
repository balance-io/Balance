import UIKit
import SPDiffable
import BlockiesSwift
import NativeUIKit

extension SPDiffableTableDataSource.CellProvider {
    
    public static var address: SPDiffableTableDataSource.CellProvider  {
        return SPDiffableTableDataSource.CellProvider() { (tableView, indexPath, item) -> UITableViewCell? in
            guard let item = item as? AddressDiffableItem else { return nil }
            let cell = tableView.dequeueReusableCell(withClass: NativeLeftButtonTableViewCell.self, for: indexPath)
            
            cell.textLabel?.text = item.text
            cell.textLabel?.numberOfLines = 2
            cell.textLabel?.adjustsFontSizeToFitWidth = true
            cell.textLabel?.minimumScaleFactor = 0.1
            
            let attrString = WalletController.formatETHAddress(
                item.text,
                textColor: .tint,
                normalFont: UIFont.preferredFont(forTextStyle: .body, weight: .medium, addPoints: 1).monospaced,
                higlightFont: UIFont.preferredFont(forTextStyle: .body, weight: .bold, addPoints: 1).monospaced
            )
            cell.textLabel?.attributedText = attrString
            
            cell.detailTextLabel?.text = item.detail
            cell.detailTextLabel?.textColor = item.detailColor
            cell.imageView?.image = item.icon
            cell.accessoryType = item.accessoryType
            cell.higlightStyle = .content
            return cell
        }
    }
    
    public static var wallet: SPDiffableTableDataSource.CellProvider  {
        return SPDiffableTableDataSource.CellProvider() { (tableView, indexPath, item) -> UITableViewCell? in
            guard let wrapperItem = item as? SPDiffableWrapperItem else { return nil }
            guard let walletModel = wrapperItem.model as? TokenaryWallet else { return nil }
            let cell = tableView.dequeueReusableCell(withClass: WalletTableViewCell.self, for: indexPath)
            
            let addAddress = {
                var formattedAddress = walletModel.ethereumAddress ?? .space
                formattedAddress.insert("\n", at: formattedAddress.index(formattedAddress.startIndex, offsetBy: (formattedAddress.count / 2)))
                
                cell.addressLabel.text = formattedAddress
                cell.addressLabel.minimumScaleFactor = 0.1
                cell.addressLabel.numberOfLines = 2
                cell.addressLabel.adjustsFontSizeToFitWidth = true
                
                let attrString = WalletController.formatETHAddress(
                    formattedAddress,
                    textColor: .secondaryLabel,
                    normalFont: UIFont.preferredFont(forTextStyle: .body, weight: .regular, addPoints: -2).monospaced,
                    higlightFont: UIFont.preferredFont(forTextStyle: .body, weight: .bold, addPoints: -2).monospaced
                )
                cell.addressLabel.attributedText = attrString
            }
            
            let addName = {
                if let name = walletModel.walletName?.trim, !name.isEmptyContent {
                    cell.titleLabel.text = name
                    cell.titleLabel.textColor = .label
                } else {
                    cell.titleLabel.text = Texts.Wallet.no_name
                    cell.titleLabel.textColor = .secondaryLabel
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
                    cell.avatarView.avatarAppearance = .avatar(image)
                }
            }
            
            cell.layoutSubviews()
            
            return cell
        }
    }
}
