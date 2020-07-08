//
//  BookHeaderCollectionViewCell.swift
//  Bookstagram
//
//  Created by Vishaal Kumar on 6/23/20.
//  Copyright © 2020 Vishaal Kumar. All rights reserved.
//

import UIKit

class BookHeaderCollectionViewCell: UICollectionViewCell {
    
    let bookImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.backgroundColor = .black
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(bookImageView)
        bookImageView.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: frame.height, height: frame.height)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
