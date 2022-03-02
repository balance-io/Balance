import UIKit
import QRScanner

final class QRCodeScanningController: UIViewController, QRScannerViewDelegate {
    
    let qrScannerView = QRScannerView()
    let completion: (String, QRCodeScanningController)->Void
    
    init(completion: @escaping (String, QRCodeScanningController)->Void) {
        self.completion = completion
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        view.addSubview(qrScannerView)
        qrScannerView.setEqualSuperviewBounds()
        qrScannerView.configure(delegate: self)
        qrScannerView.startRunning()
        
        navigationController?.navigationBar.setAppearance(.transparentAlways)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        qrScannerView.setEqualSuperviewBounds()
    }
    
    // MARK: - QRScannerViewDelegate
    
    func qrScannerView(_ qrScannerView: QRScannerView, didFailure error: QRScannerError) {
        print(error)
    }

    func qrScannerView(_ qrScannerView: QRScannerView, didSuccess code: String) {
        print("code \(code)")
        completion(code, self)
    }
}
