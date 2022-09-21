//  Created by Luke Zhao on 6/14/21.

import UIComponent
import UIKit

struct ImageData {
    let url: URL
    let size: CGSize
}

class AsyncImageViewController: ComponentViewController {
    var images = [
        ImageData(
            url: URL(string: "https://unsplash.com/photos/Yn0l7uwBrpw/download?force=true&w=640")!,
            size: CGSize(width: 640, height: 360)
        ),
        ImageData(
            url: URL(string: "https://unsplash.com/photos/J4-xolC4CCU/download?force=true&w=640")!,
            size: CGSize(width: 640, height: 800)
        ),
        ImageData(
            url: URL(string: "https://unsplash.com/photos/biggKnv1Oag/download?force=true&w=640")!,
            size: CGSize(width: 640, height: 434)
        ),
        ImageData(
            url: URL(string: "https://unsplash.com/photos/MR2A97jFDAs/download?force=true&w=640")!,
            size: CGSize(width: 640, height: 959)
        ),
        ImageData(
            url: URL(string: "https://unsplash.com/photos/oaCnDk89aho/download?force=true&w=640")!,
            size: CGSize(width: 640, height: 426)
        ),
        ImageData(
            url: URL(string: "https://unsplash.com/photos/MOfETox0bkE/download?force=true&w=640")!,
            size: CGSize(width: 640, height: 426)
        ),
    ] {
        didSet {
            reloadComponent()
        }
    }

    override var component: Component {
        Waterfall(columns: 2, spacing: 1) {
            for (index, image) in images.enumerated() {
                AsyncImage(image.url)
                    .size(width: .fill, height: .aspectPercentage(image.size.height / image.size.width))
                    .tappableView {
                        let detailVC = AsyncImageDetailViewController()
                        detailVC.image = image
                        $0.parentViewController?.navigationController?.pushViewController(detailVC, animated: true)
                    }
                    .previewBackgroundColor(.systemBackground.withAlphaComponent(0.7))
                    .previewProvider {
                        let detailVC = AsyncImageDetailViewController()
                        detailVC.image = image
                        detailVC.preferredContentSize = image.size
                        detailVC.view.backgroundColor = .clear
                        return detailVC
                    }
                    .contextMenuProvider { [weak self] _ in
                        UIMenu(children: [
                            UIAction(
                                title: "Delete",
                                image: UIImage(systemName: "trash"),
                                attributes: [.destructive],
                                handler: { action in
                                    self?.images.remove(at: index)
                                }
                            )
                        ])
                    }
                    .id(image.url.absoluteString)
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        componentView.animator = AnimatedReloadAnimator()
        title = "Async Image"
    }
}

class AsyncImageDetailViewController: ComponentViewController {
    var image: ImageData!

    override var component: Component {
        VStack {
            AsyncImage(image.url)
                .size(width: .fill, height: .aspectPercentage(image.size.height / image.size.width))
                .tappableView {
                    $0.parentViewController?.navigationController?.popViewController(animated: true)
                }
        }
    }
}
