import UIKit
import Kingfisher
import ProgressHUD

class ImagesListViewController: UIViewController {
    @IBOutlet private var tableView: UITableView!
    private let imagesListService = ImagesListService.shared
    private let showSingleImageSegueIdentifier = "ShowSingleImage"
    private var photos: [Photo] = []
    private let placeholderImage = UIImage(resource: .placeholder)
    private var ImagesListObserver: NSObjectProtocol?
    private lazy var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d MMMM yyyy"
        dateFormatter.locale = Locale(identifier: "ru_RU")
        return dateFormatter
    } ()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = 200
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        
        imagesListService.fetchPhotosNextPage(){ _ in
            
        }
        
        ImagesListObserver = NotificationCenter.default.addObserver(
            forName: ImagesListService.didChangeNotification,
            object: nil,
            queue: .main) { [weak self] _ in
                guard let self else { return }
                
                let oldPhotosCount = self.photos.count
                self.photos = ImagesListService.shared.photos
                let newPhotosCount = self.photos.count
                
                guard newPhotosCount > oldPhotosCount else { return }
                
                let indexPaths: [IndexPath] = (oldPhotosCount..<newPhotosCount).map(){
                    IndexPath(row: $0, section: 0)
                }
                
                tableView.performBatchUpdates(){
                    self.tableView.insertRows(at: indexPaths, with: .automatic)
                } completion: { finished in
                    switch finished{
                    case true:
                        print("[performBatchUpdates]: finished")
                    case false:
                        print("[performBatchUpdates]: not finished, animations were interrupted for any reason")
                    }
                }
                return
            }
    }
    
    private func showError(indexPath: IndexPath, destinationViewController: SingleImageViewController) {
        let alert = UIAlertController(title: "Ошибка", message: "Что-то пошло не так. Попробовать ещё раз?", preferredStyle: .alert)
        let action = UIAlertAction(title: "Не надо", style: .default, handler: nil)
        let action2 = UIAlertAction(title: "Попробовать ещё раз", style: .default) { [weak self] _ in
            guard let self else { return }
            if let photoURL = URL(string: self.photos[indexPath.row].largeImageURL) {
                let imageView = UIImageView()
                UIBlockingProgressHUD.show()
                imageView.kf.setImage(with: photoURL, placeholder: placeholderImage, options: [
                    .cacheOriginalImage
                ]){ _ in
                    UIBlockingProgressHUD.dismiss()
                    destinationViewController.image = imageView.image
                }
            }
        }
        alert.addAction(action)
        alert.addAction(action2)
        present(alert, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showSingleImageSegueIdentifier {
            guard
                let destinationViewController = segue.destination as? SingleImageViewController,
                let indexPath = sender as? IndexPath
            else {
                assertionFailure("Invalid segue destination or sender")
                return
            }
            
            if let photoURL = URL(string: photos[indexPath.row].largeImageURL) {
                let imageView = UIImageView()
                UIBlockingProgressHUD.show()
                imageView.kf.setImage(with: photoURL, placeholder: placeholderImage, options: [
                    .cacheOriginalImage
                ]){ _ in
                    UIBlockingProgressHUD.dismiss()
                    destinationViewController.image = imageView.image
                }
            } else {
                showError(indexPath: indexPath, destinationViewController: destinationViewController)
            }
        }
        else {
            super.prepare(for: segue, sender: sender)
        }
    }
    
    private func config(for cell: ImagesListCell, with indexPath: IndexPath){
        let photo = photos[indexPath.row]
        if let imageURL = URL(string: photo.largeImageURL) {
            cell.cellImage.kf.indicatorType = .activity
            cell.cellImage.kf.setImage(with: imageURL, placeholder: placeholderImage, options: [
                .cacheOriginalImage
            ]) { _ in
                self.tableView.reloadRows(at: [indexPath], with: .automatic)
            }
            
            if let date = photo.createdAt{
                cell.dateLabel.text = dateFormatter.string(from: date)
            } else {
                cell.dateLabel.text = dateFormatter.string(from: Date())
            }
        }
        else {
            cell.cellImage.image = placeholderImage
        }
        
        let isLiked = photo.isLiked
        let likeImage = isLiked ? UIImage(resource: .likeButtonActive) : UIImage(resource: .likeButtonNoActive)
        cell.likeButton.setImage(likeImage, for: .normal)
        
        cell.delegate = self
    }
    
    
}

extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath)
        
        guard let imageListCell = cell as? ImagesListCell else {
            return UITableViewCell()
        }
        config(for: imageListCell, with: indexPath)
        return imageListCell
    }
}

extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: showSingleImageSegueIdentifier, sender: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let photo = photos[indexPath.row]
        let imageWidth = photo.size.width
        let imageHeight = photo.size.height
        let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let imageViewWidth = tableView.bounds.width - imageInsets.left - imageInsets.right
        let ratio = imageViewWidth / imageWidth
        let cellHeight = imageHeight * ratio + imageInsets.top + imageInsets.bottom
        return cellHeight
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == imagesListService.photos.count - 1  {
            imagesListService.fetchPhotosNextPage() { _ in
                
            }
        }
    }
}

extension ImagesListViewController: ImagesListCellDelegate {
    func imageListCellDidTapLike(cell: ImagesListCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        self.photos = self.imagesListService.photos
        let photoID = photos[indexPath.row].id
        let isLike = !photos[indexPath.row].isLiked
        UIBlockingProgressHUD.show()
        imagesListService.changeLike(photoID: photoID, isLike: isLike){ [weak self] result in
            guard let self else { return }
            
            switch result {
            case .success():
                
                self.photos = self.imagesListService.photos
                cell.changeLikeButtonState(self.photos[indexPath.row].isLiked)
                
                UIBlockingProgressHUD.dismiss()
                
            case .failure(let error):
                UIBlockingProgressHUD.dismiss()
                print("[imageListCellDidTapLike]: error: \(error)")
                
                let alert = UIAlertController(title: "Ошибка", message: "Что-то пошло не так, попробуйте позже", preferredStyle: .alert)
                let alertAction = UIAlertAction(title: "Окей", style: .default, handler: nil)
                alert.addAction(alertAction)
                self.present(alert, animated: true, completion: nil)
            }
            
        }
    }
}
