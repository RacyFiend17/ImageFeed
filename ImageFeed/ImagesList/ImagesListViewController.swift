import UIKit
import Kingfisher
import ProgressHUD

final class ImagesListViewController: UIViewController, ImagesListViewControllerProtocol {
    var presenter: ImagesListPresenterProtocol?
    @IBOutlet private var tableView: UITableView!
    private let showSingleImageSegueIdentifier = "ShowSingleImage"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter?.viewDidLoad()
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
    }
    
    func configure(presenter: ImagesListPresenterProtocol){
        self.presenter = presenter
        presenter.view = self
    }
    
    func insertRows(at indexPaths: [IndexPath]) {
            self.tableView.insertRows(at: indexPaths, with: .automatic)
    }
    
    func showLoading() {
        UIBlockingProgressHUD.show()
    }
    
    func dismissLoading() {
        UIBlockingProgressHUD.dismiss()
    }
    
    private func makeErrorAlert() -> UIAlertController {
        let alert = UIAlertController(title: "Ошибка", message: "Что-то пошло не так, попробуйте позже", preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "Окей", style: .default, handler: nil)
        alert.addAction(alertAction)
        
        return alert
    }
    
    func showErrorAlert() {
        let alert = makeErrorAlert()
        self.present(alert, animated: true, completion: nil)
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
            
            destinationViewController.imageURLString = presenter?.largeURLStringAt(index: indexPath.row)
        }
        else {
            super.prepare(for: segue, sender: sender)
        }
    }

    private func config(for cell: ImagesListCell, with indexPath: IndexPath){
        guard let presenter = presenter else {
            cell.cellImage.image = UIImage(resource: .placeholder)
            cell.likeButton.setImage(UIImage(resource: .likeButtonNoActive), for: .normal)
            cell.dateLabel.text = nil
            print("Can't config cell, presenter is nil")
            return
        }
        
        let photoLargeImageURLString = presenter.largeURLStringAt(index: indexPath.row)
        if let imageURL = URL(string: photoLargeImageURLString) {
            cell.cellImage.image = UIImage(resource: .placeholder)
            cell.cellImage.kf.indicatorType = .activity
            cell.cellImage.kf.setImage(with: imageURL, placeholder: UIImage(resource: .placeholder), options: [.cacheOriginalImage]) { [weak self, weak cell] result in
                guard let self = self, let cell = cell else { return }
                
                if let currentIndexPath = self.tableView.indexPath(for: cell), currentIndexPath == indexPath {
                    
                    cell.dateLabel.text = presenter.dateTextAt(index: indexPath.row)
                    
                    let isLiked = presenter.isLikedAt(index: indexPath.row)
                    let likeImage = isLiked ? UIImage(resource: .likeButtonActive) : UIImage(resource: .likeButtonNoActive)
                    cell.likeButton.setImage(likeImage, for: .normal)
                }
                
                else {
                    cell.cellImage.image = UIImage(resource: .placeholder)
                    cell.likeButton.setImage(UIImage(resource: .likeButtonNoActive), for: .normal)
                    cell.dateLabel.text = presenter.todayDateFormattedString()
                }
                
                cell.delegate = self
            }
        }
    }
}

extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        presenter?.numberOfRows() ?? 0
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
        let photoSize = presenter?.photoSizeAt(index: indexPath.row) ?? CGSize(width: 0, height: 0)
        let imageWidth = photoSize.width
        let imageHeight = photoSize.height
        let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let imageViewWidth = tableView.bounds.width - imageInsets.left - imageInsets.right
        let ratio = imageViewWidth / imageWidth
        let cellHeight = imageHeight * ratio + imageInsets.top + imageInsets.bottom
        return cellHeight
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        presenter?.willDisplayLastRowIfNeeded(currentIndex: indexPath.row)
    }
}

extension ImagesListViewController: ImagesListCellDelegate {
    func imageListCellDidTapLike(_ cell: ImagesListCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }

                // ask presenter to do work; presenter will call service and then invoke completion to update cell UI
                presenter?.didTapLike(at: indexPath.row) { [weak cell] isLiked in
                    DispatchQueue.main.async {
                        cell?.changeLikeButtonState(isLiked)
                    }
                }
    }
}


public protocol ImagesListViewControllerProtocol {
    var presenter: ImagesListPresenterProtocol? { get set }
    func configure(presenter: ImagesListPresenterProtocol)
    func insertRows(at indexPaths: [IndexPath])
    func showLoading()
    func dismissLoading()
    func showErrorAlert()
}
