import UIKit
import SparrowKit
import NativeUIKit

extension Presenter {
    
    enum App {
        
        static func showOnboarding(on viewController: UIViewController, afterAction: @escaping (()->Void)) {
            let controller = Controllers.App.Onboarding.container
            controller.endAction = afterAction
            applyForm(.modalForm, to: controller)
            viewController.present(controller)
        }
        
        static func showSafariIntegrationSteps(on viewController: UIViewController) {
            let controller = Controllers.App.safari_steps
            let navigationController = NativeNavigationController(rootViewController: controller)
            controller.navigationItem.rightBarButtonItem = controller.closeBarButtonItem
            applyForm(.modalForm, to: navigationController)
            viewController.present(navigationController)
        }
        
        static func showQRCodeScanningController(completion: @escaping (String, QRCodeScanningController)->Void, on viewController: UIViewController) {
            let controller = Controllers.App.qr_code_scanning(completion: completion)
            let navigationController = controller.wrapToNavigationController(prefersLargeTitles: false)
            controller.navigationItem.rightBarButtonItem = controller.closeBarButtonItem
            applyForm(.fullScreen, to: navigationController)
            viewController.present(navigationController)
        }
        
        enum Settings {
            
            static func showLanguages(on navigationController: UINavigationController) {
                let controller = Controllers.App.Settings.languages
                navigationController.pushViewController(controller, completion: nil)
            }
            
            static func showAppearance(on navigationController: UINavigationController) {
                let controller = Controllers.App.Settings.appearance
                navigationController.pushViewController(controller, completion: nil)
            }
            
            static func showWalletStyle(on navigationController: UINavigationController) {
                let controller = Controllers.App.Settings.wallet_style
                navigationController.pushViewController(controller, completion: nil)
            }
        }
    }
}
