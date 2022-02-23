import UIKit
import SparrowKit
import NativeUIKit

enum Navigation {
    
    // MARK: - Controllers
    
    static var rootController: UIViewController {
        return SideBarSplitController()
    }
    
    static var compactRootController: UIViewController {
        return TabBarController()
    }
    
    // MARK: - Bars
    
    static var tabBars: [BarRowModel] {
        return basicBars(for: .tabBar)
    }
    
    static var sideBars: [BarSectionModel] {
        return [
            BarSectionModel(.main, items: basicBars(for: .sideBar))
        ]
    }
    
    // MARK: - Internal
    
    private static func basicBars(for usage: BarUsage) -> [BarRowModel] {
        // Sent hidden becouse in develop process now.
        let barItems = [BarRowModel.Item.wallets, .nft, .settings]
        return barItems.map { (barItem) -> BarRowModel in
            let identifier = usage.id + barItem.id
            return BarRowModel.init(
                id: identifier,
                title: barItem.title,
                image: barItem.image,
                getController: {
                    if let controller = Cache.getController(by: identifier) {
                        return controller
                    } else {
                        let controller = createController(for: barItem)
                        if usage.allowCacheControllers {
                            Cache.appendController(controller, for: identifier)
                        }
                        return controller
                    }
                }
            )
        }
    }
    
    private static func createController(for barItem: BarRowModel.Item) -> UINavigationController {
        let controller = barItem.controller
        let allowLargeTitles = UIDevice.current.isMac ? false : true
        let navigationController = NativeNavigationController(rootViewController: controller)
        navigationController.navigationBar.prefersLargeTitles = allowLargeTitles
        return navigationController
    }
}
