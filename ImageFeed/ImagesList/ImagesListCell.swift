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
    
    @IBAction func likeButtonClicked(_ sender: Any) {
        delegate?.imageListCellDidTapLike(cell: self)
    }
    
    func changeLikeButtonState(_ isLiked: Bool) {
        if isLiked {
            likeButton.setImage(UIImage(resource: .likeButtonActive), for: .normal)
        } else {
            likeButton.setImage(UIImage(resource: .likeButtonNoActive), for: .normal)
        }
    }
    
}

protocol ImagesListCellDelegate: AnyObject {
    func imageListCellDidTapLike(cell: ImagesListCell)
}
