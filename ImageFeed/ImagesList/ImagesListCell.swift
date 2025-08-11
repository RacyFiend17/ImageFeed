//
//  ImagesListCell.swift
//  ImageFeed
//
//  Created by Дмитрий Перчемиди on 10.08.2025.
//

import UIKit

final class ImagesListCell: UITableViewCell {
    static let reuseIdentifier = "ImagesListCell"
    
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var cellImage: UIImageView!
}
