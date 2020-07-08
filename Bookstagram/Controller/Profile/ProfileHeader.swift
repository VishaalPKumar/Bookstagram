//
//  ProfileHeader.swift
//  Bookstagram
//
//  Created by Vishaal Kumar on 6/19/20.
//  Copyright © 2020 Vishaal Kumar. All rights reserved.
//

import UIKit
import Firebase

protocol ProfileHeaderDelegate {
    func didChangeToListView()
    func didChangeToGridView()
}
class ProfileHeader: UICollectionViewCell {
    
    var delegate: ProfileHeaderDelegate?
    
    var currentUser: User? {
        didSet{
            guard let profileImageURL = currentUser?.profileImageURL else {return}
            profileImageView.loadImage(urlString: profileImageURL)
            usernameLabel.text = currentUser?.username
            
            setupEditButton()
        }
    }
    //MARK: - Designing View
    
    fileprivate func setupEditButton() {
        guard let currentLoggedInUserID = Auth.auth().currentUser?.uid else {return}
        guard let userID = currentUser?.uid else {return}
        
        if currentLoggedInUserID == userID {
            
        } else {
            Database.database().reference().child("following").child(currentLoggedInUserID).child(userID).observeSingleEvent(of: .value, with: { (snapshot) in
                
                if let isFollowing = snapshot.value as? Int, isFollowing == 1 {
                    self.setupUnfollowStyle()
                } else {
                    self.setupFollowStyle()
                }
                
            }) { (error) in
                print("Error in checking whether already following \(error)")
            }
            

        }
    }
    
    @objc func handleEditProfileOrFollow() {
        print("Execute edit profile / follow / unfollow logic...")
        
        guard let currentLoggedInUserId = Auth.auth().currentUser?.uid else { return }
        
        guard let userId = currentUser?.uid else { return }
        
        if editProfileButton.titleLabel?.text == "Unfollow" {
            
            //unfollow
            Database.database().reference().child("following").child(currentLoggedInUserId).child(userId).removeValue(completionBlock: { (err, ref) in
                if let err = err {
                    print("Failed to unfollow user:", err)
                    return
                }
                
                print("Successfully unfollowed user:", self.currentUser?.username ?? "")
                
                self.setupFollowStyle()
            })
            
        } else {
            //follow
            let ref = Database.database().reference().child("following").child(currentLoggedInUserId)
            
            let values = [userId: 1]
            ref.updateChildValues(values) { (err, ref) in
                if let err = err {
                    print("Failed to follow user:", err)
                    return
                }
                
                print("Successfully followed user: ", self.currentUser?.username ?? "")
                
                self.setupUnfollowStyle()
            }
        }
    }
    
    let profileImageView: CustomImageView = {
        let imageView = CustomImageView()
        imageView.layer.borderColor = UIColor(named: "Button Color")?.cgColor
        imageView.layer.borderWidth = 3
        return imageView
    }()
    
    lazy var gridButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "circle.grid.3x3.fill"), for: .normal)
        button.backgroundColor = UIColor(named: "Text Color")?.withAlphaComponent(0.2)
        button.tintColor = UIColor(named: "Button Color")
        button.addTarget(self, action: #selector(handleGridView), for: .touchUpInside)
        return button
    }()
    @objc func handleGridView() {
        print("Displaying Grid View..")
        listButton.setImage(UIImage(systemName: "list.bullet"), for: .normal)
        gridButton.setImage(UIImage(systemName: "circle.grid.3x3.fill"), for: .normal)
        gridButton.backgroundColor = UIColor(named: "Text Color")?.withAlphaComponent(0.2)
        listButton.backgroundColor = nil
        delegate?.didChangeToGridView()

    }
    
    
    lazy var listButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "list.bullet"), for: .normal)
        button.tintColor = UIColor(named: "Button Color")
        button.addTarget(self, action: #selector(handleListView), for: .touchUpInside)
        return button
    }()
    
    @objc func handleListView() {
        print("Displaying List View..")
        listButton.backgroundColor = UIColor(named: "Text Color")?.withAlphaComponent(0.2)
        gridButton.setImage(UIImage(systemName: "circle.grid.3x3"), for: .normal)
        gridButton.backgroundColor = nil
        delegate?.didChangeToListView()
    }
    
    let bookmarkButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "bookmark"), for: .normal)
        button.tintColor = UIColor(named: "Button Color")
        return button
    }()
    
    let usernameLabel: UILabel = {
        let label = UILabel()
        label.text = "username"
        label.font = UIFont(name: "Helvetice-Neue-Thin", size: 12)
        label.textColor = UIColor(named: "Button Color")
        return label
    }()
    
    let postsLabel: UILabel = {
        let label = UILabel()
        
        let attributedText = NSMutableAttributedString(string: "11\n", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14)])
        
        attributedText.append(NSAttributedString(string: "posts", attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14)]))
        
        label.attributedText = attributedText
        label.textColor = UIColor(named: "Button Color")
        
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    let followersLabel: UILabel = {
        let label = UILabel()
        
        let attributedText = NSMutableAttributedString(string: "0\n", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14)])
        
        attributedText.append(NSAttributedString(string: "followers", attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14)]))
        
        label.attributedText = attributedText
        label.textColor = UIColor(named: "Button Color")
        
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    let followingLabel: UILabel = {
        let label = UILabel()
        
        let attributedText = NSMutableAttributedString(string: "0\n", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14)])
        
        attributedText.append(NSAttributedString(string: "following", attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14)]))
        
        label.attributedText = attributedText
        label.textColor = UIColor(named: "Button Color")
        
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    lazy var editProfileButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Edit Profile", for: .normal)
        button.setTitleColor(UIColor(named: "Button Color"), for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.layer.borderColor = UIColor.lightGray.cgColor
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 3
        button.addTarget(self, action: #selector(handleEditProfileOrFollow), for: .touchUpInside)
        return button
    }()
    
    fileprivate func setupFollowStyle() {
        self.editProfileButton.setTitle("Follow", for: .normal)
        self.editProfileButton.backgroundColor = UIColor(named: "Button Color")
        self.editProfileButton.setTitleColor(UIColor(named: "Text Color"), for: .normal)
    }
    
    fileprivate func setupUnfollowStyle() {
        self.editProfileButton.setTitle("Unfollow", for: .normal)
        self.editProfileButton.backgroundColor = UIColor(named: "Text Color")
        self.editProfileButton.setTitleColor(UIColor(named: "Button Color"), for: .normal)
    }
    
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = UIColor(named: "Background Color")
        layer.borderColor = UIColor(named: "Button Color")?.cgColor
        layer.borderWidth = 1
        
        addSubview(profileImageView)
        profileImageView.anchor(top: topAnchor, left: self.leftAnchor, bottom: nil, right: nil, paddingTop: 12, paddingLeft: 12, paddingBottom: 0, paddingRight: 0, width: 80, height: 80)
        profileImageView.layer.cornerRadius = 80 / 2
        profileImageView.clipsToBounds = true
        
        setUpBottomToolbar()
        positionUsernameLabel()
        setupUserStatsView()
        positionEditProfileButton()
        
    }
    
    //MARK: - Positioning Views Methods
    
    func setUpBottomToolbar() {
        let stackview = UIStackView(arrangedSubviews: [gridButton, listButton, bookmarkButton])
        
        stackview.axis = .horizontal
        stackview.distribution = .fillEqually
        
        addSubview(stackview)
        stackview.anchor(top: nil, left: leftAnchor, bottom: self.bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 50)
    }
    
    func positionUsernameLabel() {
        addSubview(usernameLabel)
        usernameLabel.anchor(top: profileImageView.bottomAnchor, left: leftAnchor, bottom: gridButton.topAnchor, right: rightAnchor, paddingTop: 4, paddingLeft: 20, paddingBottom: 0, paddingRight: 12, width: 0, height: 0)
    }
    
    func positionEditProfileButton() {
        addSubview(editProfileButton)
        editProfileButton.anchor(top: postsLabel.bottomAnchor, left: postsLabel.leftAnchor, bottom: nil, right: followingLabel.rightAnchor, paddingTop: 2, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 34)
    }
    
    func setupUserStatsView() {
        let stackView = UIStackView(arrangedSubviews: [postsLabel, followersLabel, followingLabel])
        
        stackView.distribution = .fillEqually
        
        addSubview(stackView)
        stackView.anchor(top: topAnchor, left: profileImageView.rightAnchor, bottom: nil, right: rightAnchor, paddingTop: 12, paddingLeft: 12, paddingBottom: 0, paddingRight: 12, width: 0, height: 50)
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
