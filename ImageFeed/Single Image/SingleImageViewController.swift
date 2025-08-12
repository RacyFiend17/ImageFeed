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
            guard let viewIfLoaded else {
                return
            }
            imageView.image = image
        }
    }
    @IBOutlet private var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.image = image
    }
}
