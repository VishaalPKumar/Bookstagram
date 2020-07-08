//
//  PostsCollectionViewCell.swift
//  Bookstagram
//
//  Created by Vishaal Kumar on 6/24/20.
//  Copyright © 2020 Vishaal Kumar. All rights reserved.
//

import UIKit

class PostsCollectionViewCell: UICollectionViewCell {
        
        var post: Post? {
            didSet {
                guard let imageUrl = post?.imageURL else { return }
                photoImageView.loadImage(urlString: imageUrl)
            }
        }
        
        let photoImageView: CustomImageView = {
            let imageView = CustomImageView()
            imageView.backgroundColor = nil
            imageView.contentMode = .scaleAspectFill
            imageView.clipsToBounds = true
            return imageView
        }()
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            
            addSubview(photoImageView)
            photoImageView.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: frame.width, height: frame.height)
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
    
}
