//
//  HomePostCell.swift
//  Bookstagram
//
//  Created by Vishaal Kumar on 6/25/20.
//  Copyright © 2020 Vishaal Kumar. All rights reserved.
//

import UIKit

protocol HomePostCellDelegate {
    func didTapComment(post: Post)
    func didLike(for cell: HomePostCell)
}

class HomePostCell: UICollectionViewCell {
    
    var delegate: HomePostCellDelegate?
    
    var post: Post? {
        didSet {
            guard let urlString = post?.imageURL else {
                return
            }
            photoImageView.loadImage(urlString: urlString)
            usernameLabel.text = post?.user.username
            guard let profileImageURL = post?.user.profileImageURL else {return}
            userProfileImageView.loadImage(urlString: profileImageURL)
            
            likeButton.setImage(post?.isLiked == true ? UIImage(systemName: "heart.fill") : UIImage(systemName: "heart"), for: .normal)
            
            setupAttributedCaption()
        }
    }
    
    fileprivate func setupAttributedCaption() {
        guard let post = self.post else { return }
        let bookDetails = post.bookDetails
        guard let bookName = bookDetails["bookName"] else {return}
        guard let authorName = bookDetails["authorName"] else {return}
        guard let bookRating = bookDetails["bookRating"] else {return}
        guard let bookReview = bookDetails["bookReview"] else {return}
        
        let attributedText = NSMutableAttributedString(string: post.user.username, attributes: [NSAttributedString.Key.font: UIFont(name: "Avenir-Heavy", size: 17)!])
        attributedText.append(NSAttributedString(string: "\nBook Name : \(bookName)", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14)]))
         attributedText.append(NSAttributedString(string: "\nAuthor Name : \(authorName)", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14)]))
         attributedText.append(NSAttributedString(string: "\nRating : \(bookRating)", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14)]))
         attributedText.append(NSAttributedString(string: "\nReview : \(bookReview)", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14)]))
        
        attributedText.append(NSAttributedString(string: "\n\n", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 4)]))
        
        let timeAgoDisplayed = post.creationDate.timeAgoDisplay()
        attributedText.append(NSAttributedString(string: "\(timeAgoDisplayed)", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor.gray]))
        
        attributedText.append(NSAttributedString(string: "\n\n", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 4)]))
        
        captionLabel.textColor = UIColor(named: "Button Color")
        captionLabel.attributedText = attributedText
    }
    
    let userProfileImageView: CustomImageView = {
        let imageView = CustomImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.borderColor = UIColor.black.cgColor
        imageView.layer.borderWidth = 1
        return imageView
    }()
    
    let photoImageView: CustomImageView = {
        let imageView = CustomImageView()
        imageView.layer.borderColor = UIColor.white.cgColor
        imageView.layer.borderWidth = 3
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    let usernameLabel: UILabel = {
        let label = UILabel()
        let username = "Username"
        let myAttribute: [NSAttributedString.Key : Any] = [ NSAttributedString.Key.foregroundColor: UIColor(named: "Text Color")!,
                                                            NSAttributedString.Key.font: UIFont(name: "Avenir-Book", size: 17)!]
        let attrString = NSAttributedString(string: username, attributes: myAttribute)
        label.attributedText = attrString
        return label
    }()
    
    let optionsButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("•••", for: .normal)
        button.setTitleColor(UIColor(named: "Button Color"), for: .normal)
        return button
    }()
    
    lazy var likeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "heart"), for: .normal)
        button.tintColor = UIColor(named: "Button Color")
        button.addTarget(self, action: #selector(handleLike), for: .touchUpInside)
        return button
    }()
    
    @objc func handleLike() {
        print("Handling like from within the cell")
        delegate?.didLike(for: self)
    }
    
    lazy var commentButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "text.bubble"), for: .normal)
        button.tintColor = UIColor(named: "Button Color")
        button.addTarget(self, action: #selector(handleComment), for: .touchUpInside)
        return button
    }()
    
    @objc func handleComment() {
        print("Showing comments..")
        guard let post = post else { return }
        delegate?.didTapComment(post: post)
    }
    
    let sendMessageButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "paperplane"), for: .normal)
        button.tintColor = UIColor(named: "Button Color")
        return button
    }()
    
    let bookmarkButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "bookmark"), for: .normal)
        button.tintColor = UIColor(named: "Button Color")
        return button
    }()
    
    let captionLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = UIColor(named: "Background Color")
        layer.borderColor = UIColor(named: "Text Color")?.cgColor
        layer.borderWidth = 1
        addSubview(userProfileImageView)
        addSubview(usernameLabel)
        addSubview(optionsButton)
        addSubview(photoImageView)
        
        userProfileImageView.anchor(top: self.topAnchor, left: self.leftAnchor, bottom: nil, right: nil, paddingTop: 8, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 40, height: 40)
        userProfileImageView.layer.cornerRadius = 40 / 2
        
        usernameLabel.anchor(top: self.topAnchor, left: userProfileImageView.rightAnchor, bottom: photoImageView.topAnchor, right: optionsButton.leftAnchor, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        
        optionsButton.anchor(top: self.topAnchor, left: nil, bottom: photoImageView.topAnchor, right: self.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 44, height: 0)
        
        photoImageView.anchor(top: userProfileImageView.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 8, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: self.frame.width, height: self.frame.width)
        
        
        setupActionButtons()
        
        addSubview(captionLabel)
        captionLabel.anchor(top: likeButton.bottomAnchor, left: leftAnchor, bottom: bottomAnchor, right: self.rightAnchor, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 8, width: self.frame.width, height: 0)
        
    }
    
    fileprivate func setupActionButtons() {
        let stackView = UIStackView(arrangedSubviews: [likeButton, commentButton, sendMessageButton])
        
        stackView.distribution = .fillEqually
        
        addSubview(stackView)
        stackView.anchor(top: photoImageView.bottomAnchor, left: self.leftAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 4, paddingBottom: 0, paddingRight: 0, width: 120, height: 50)
        
        addSubview(bookmarkButton)
        bookmarkButton.anchor(top: photoImageView.bottomAnchor, left: nil, bottom: nil, right: self.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 40, height: 50)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
