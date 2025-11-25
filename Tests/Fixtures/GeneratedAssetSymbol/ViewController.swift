import UIKit

final class FlagViewController: UIViewController {
    private let flagImage = UIImage.icFlag
    private let highlightedImage: UIImage = .icFlagHighlighted
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure(image: .icFlagSecondary)
    }
    
    private func configure(image: UIImage) {
        let tinted = image.withRenderingMode(.alwaysTemplate)
        _ = tinted.withTintColor(.blue)
    }
}
