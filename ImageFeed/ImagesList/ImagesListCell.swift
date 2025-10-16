import UIKit
import Kingfisher

final class ImagesListCell: UITableViewCell {
    weak var delegate: ImagesListCellDelegate?
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
    
    @IBAction private func likeButtonClicked(_ sender: Any) {
        delegate?.imageListCellDidTapLike(self)
    }
    
    func changeLikeButtonState(_ isLiked: Bool) {
            likeButton.setImage(UIImage(resource: isLiked ? .likeButtonActive : .likeButtonNoActive), for: .normal)
    }
}

protocol ImagesListCellDelegate: AnyObject {
    func imageListCellDidTapLike(_ cell: ImagesListCell)
}
