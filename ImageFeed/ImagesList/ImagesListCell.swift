import UIKit
import Kingfisher

final class ImagesListCell: UITableViewCell {
    static let reuseIdentifier = "ImagesListCell"
    
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var cellImage: UIImageView!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        cellImage.kf.cancelDownloadTask()
        cellImage.image = UIImage(resource: .placeholder)
        dateLabel.text = nil
        likeButton.setImage(nil, for: .normal)
    }
}
