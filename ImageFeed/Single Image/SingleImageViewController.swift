//
//  SingleImageViewController.swift
//  ImageFeed
//
//  Created by Дмитрий Перчемиди on 12.08.2025.
//

import UIKit

final class SingleImageViewController: UIViewController {
    var image: UIImage? {
        didSet {
            updateImageView()
        }
    }
    @IBOutlet private var scrollView: UIScrollView!
    @IBOutlet private var imageView: UIImageView!
    @IBAction private func didTapBackButton(){
        dismiss(animated: true, completion: nil)
    }
    @IBAction func didTapShareButton(_ sender: UIButton) {
        let activityViewController = UIActivityViewController(activityItems: [image!], applicationActivities: nil)
        present(activityViewController, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.minimumZoomScale = 0.1
        scrollView.maximumZoomScale = 1.25
        updateImageView()
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
    
    private func updateImageView() {
        guard isViewLoaded, let image else { return }
        imageView.image = image
        imageView.frame.size = image.size
        rescaleAndCenterImageInScrollView(image: image)
    }
}

extension SingleImageViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
}
