import UIKit

final class SingleImageViewController: UIViewController {
    
    var imageURLString: String?{
        didSet {
            loadImageFromURL()
        }
    }
    
    @IBOutlet private var scrollView: UIScrollView!
    @IBOutlet private var imageView: UIImageView!
    @IBAction private func didTapBackButton(){
        dismiss(animated: true, completion: nil)
    }
    @IBAction func didTapShareButton(_ sender: UIButton) {
        guard let image = imageView.image else { return }
        let activityViewController = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        present(activityViewController, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.minimumZoomScale = 0.1
        scrollView.maximumZoomScale = 1.25
        imageView.contentMode = .center
        loadImageFromURL()
    }
    
    private func rescaleAndCenterImageInScrollView(image: UIImage) {
        let minimumZoomScale = scrollView.minimumZoomScale
        let maximumZoomScale = scrollView.maximumZoomScale
        view.layoutIfNeeded()
        let visibleRectSize = scrollView.bounds.size
        let imageSize = image.size
        let vScale = visibleRectSize.width / imageSize.width
        let hScale = visibleRectSize.height / imageSize.height
        let scale = min(max(minimumZoomScale, min(vScale, hScale)), maximumZoomScale)
        scrollView.setZoomScale(scale, animated: false)
        scrollView.layoutIfNeeded()
        let contentSize = scrollView.contentSize
        let x = (contentSize.width - scrollView.bounds.size.width) / 2
        let y = (contentSize.height - scrollView.bounds.size.height) / 2
        scrollView.setContentOffset(CGPoint(x: x, y: y), animated: false)
    }
    
    private func loadImageFromURL(){
        guard isViewLoaded, let imageURLString else { return }
        if let imageURL = URL(string: imageURLString) {
            UIBlockingProgressHUD.show()
            imageView.kf.setImage(with: imageURL, placeholder: UIImage(resource: .placeholder), options: [
                .cacheOriginalImage
            ]){ [weak self] result in
                UIBlockingProgressHUD.dismiss()
                guard let self else { return }
                
                switch result {
                case .success(let imageResult):
                    self.imageView.frame.size = imageResult.image.size
                    self.rescaleAndCenterImageInScrollView(image: imageResult.image)
                case .failure:
                    self.showError()
                }
            }
        }
    }
    
    private func showError() {
        let alert = UIAlertController(title: "Ошибка", message: "Что-то пошло не так. Попробовать ещё раз?", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Не надо", style: .default, handler: nil)
        let retryAction = UIAlertAction(title: "Попробовать ещё раз", style: .default) { [weak self] _ in
            self?.loadImageFromURL()
        }
        alert.addAction(cancelAction)
        alert.addAction(retryAction)
        present(alert, animated: true, completion: nil)
    }

}

extension SingleImageViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
            scrollView.layoutIfNeeded()
            UIView.animate(withDuration: 0.2) {
                if let image = self.imageView.image {
                    self.rescaleAndCenterImageInScrollView(image: image)
                }
            }
        }
        
    }
    
}

