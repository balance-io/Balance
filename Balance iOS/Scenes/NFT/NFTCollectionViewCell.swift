import UIKit
import SparrowKit
import Nuke
import SVGKit
import WebKit

internal var cachedSVGs: [(url: URL, image: UIImage)] = []

class NFTCollectionViewCell: SPCollectionViewCell {
    
    let indicatorView = UIActivityIndicatorView()
    let imageContainerView = SPView().do {
        $0.masksToBounds = true
    }
    let imageView = SPImageView(image: nil, contentMode: .scaleAspectFill)
    
    let nameLabel = SPLabel().do {
        $0.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        $0.textColor = .label.alpha(0.9)
    }
    
    override var isHighlighted: Bool {
        didSet {
            UIView.animate(withDuration: 0.14, delay: .zero, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: [.beginFromCurrentState], animations: {
                self.transform = self.isHighlighted ? .init(scale: 0.95) : .identity
            })
        }
    }
    
    override func commonInit() {
        super.commonInit()
        contentView.roundCorners(radius: 8)
        contentView.backgroundColor = .secondarySystemGroupedBackground
        contentView.addSubview(imageContainerView)
        imageContainerView.addSubview(imageView)
        contentView.addSubview(indicatorView)
        contentView.addSubview(nameLabel)
        contentView.layer.masksToBounds = true
        indicatorView.startAnimating()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if transform != .identity { return }
        
        imageContainerView.frame = .init(x: .zero, y: .zero, side: contentView.frame.width)
        imageView.setEqualSuperviewBounds()
        indicatorView.center = .init(x: imageContainerView.frame.width / 2, y: imageContainerView.frame.height / 2)
        
        nameLabel.layoutDynamicHeight(width: contentView.layoutWidth)
        nameLabel.setXCenter()
        nameLabel.setMaxYToSuperviewBottomMargin()
    }
    
    func setNFT(_ model: NFTModel) {
        nameLabel.text = model.name
        let url = model.imageURL
        if url.absoluteString.hasSuffix(".svg") {
            if let data = cachedSVGs.first(where: { $0.url == url }) {
                self.imageView.image = data.image
                self.indicatorView.stopAnimating()
            } else {
                DispatchQueue.global(qos: .background).async {
                    if let data = try? Data(contentsOf: url) {
                        let receivedimage = SVGKImage(data: data)
                        DispatchQueue.main.async {
                            if let image = receivedimage?.uiImage {
                                self.imageView.image = image
                                cachedSVGs.append((url: url, image: image))
                                self.indicatorView.stopAnimating()
                            }
                        }
                    }
                }
            }
        } else {
            Nuke.loadImage(with: url, into: self)
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
        indicatorView.startAnimating()
    }
}

extension NFTCollectionViewCell: Nuke_ImageDisplaying {
    
    open func nuke_display(image: UIImage?, data: Data?) {
        if let image = image {
            self.imageView.image = image
            self.indicatorView.stopAnimating()
        }
    }
}
