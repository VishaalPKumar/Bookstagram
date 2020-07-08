//
//  ShareBookViewController.swift
//  Bookstagram
//
//  Created by Vishaal Kumar on 6/30/20.
//  Copyright © 2020 Vishaal Kumar. All rights reserved.
//

import UIKit
import Cosmos
import Firebase
import Loaf

class ShareBookViewController: UIViewController {
    

    let bookImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.borderColor = UIColor.black.cgColor
        iv.layer.borderWidth = 1
        return iv
    }()
    
    let bookTitleTextField: UITextField = {
        let tf = UITextField()
        tf.font = UIFont.systemFont(ofSize: 14)
        tf.placeholder = "Book Title"
        return tf
    }()
    
    let authorNameTextField: UITextField = {
        let tf = UITextField()
        tf.font = UIFont.systemFont(ofSize: 14)
        tf.placeholder = "Author Name"
        return tf
    }()
    
    let bookReviewView: UITextView = {
        let tv = UITextView()
        tv.font = UIFont.systemFont(ofSize: 14)
        tv.text = "Book Review"
        return tv
    }()
    
    let bookRatingView: CosmosView = {
        let cv = CosmosView()
        return cv
    }()
    
    fileprivate func setupImageAndTextViews() {

        
        let fieldStackView = UIStackView(arrangedSubviews: [bookTitleTextField, authorNameTextField, bookRatingView])
        fieldStackView.axis = .vertical
        fieldStackView.distribution = .fillEqually
        
        let mainStackView = UIStackView(arrangedSubviews: [bookImageView, fieldStackView])
        mainStackView.distribution = .fillEqually
        mainStackView.spacing = 2
        view.addSubview(mainStackView)
        mainStackView.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 8, width: 0, height: 300)
        
        view.addSubview(bookReviewView)
        bookReviewView.anchor(top: mainStackView.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 10, paddingLeft: 8, paddingBottom: 0, paddingRight: 8, width: 0, height: 200)
        
        
    }
    
    
    var selectedImage: UIImage?
    
    var databaseRef: DatabaseReference!
    var storageRef: StorageReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        // Do any additional setup after loading the view.
        print(bookImageView)
        bookReviewView.layer.borderColor = UIColor(named: "Text Color")?.cgColor
        bookReviewView.layer.borderWidth = 1
        bookImageView.contentMode = .scaleAspectFit
        bookImageView.clipsToBounds = true
        if let selectedImg = selectedImage {
            bookImageView.image = selectedImg
        }
        
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing))
        view.addGestureRecognizer(tap)
        
        //Firebase Database
        databaseRef = Database.database().reference()
        //Firebase Storage
        storageRef = Storage.storage().reference()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Share", style: .plain, target: self, action: #selector(handleShare))
        
        setupImageAndTextViews()

    }
    
   
    
    fileprivate func saveToDatabaseWithImageURL(_ imageURL: String) {
        
        guard let bookName = bookTitleTextField.text else {return}
        guard let authorName = authorNameTextField.text else {return}
        guard let bookReview = bookReviewView.text else {return}
        guard let postImage = selectedImage else {return}
        let bookRating = round(bookRatingView.rating * 2) / 2

        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let userProfileReferece = databaseRef.child("posts").child(uid)
        let postRef = userProfileReferece.childByAutoId()
        
        let values = ["imageURL": imageURL,
                      "bookName": bookName,
                      "authorName": authorName,
                      "bookRating": bookRating,
                      "bookReview": bookReview,
                      "imageHeight": postImage.size.height,
                      "imageWidth": postImage.size.width,
                      "creationDate": Date().timeIntervalSince1970] as [String : Any]
        
        postRef.updateChildValues(values) { (error, databaseRef) in
            if let err = error {
                self.navigationItem.rightBarButtonItem?.isEnabled = true
                print("Error in uploading post to firebase database: \(err)")
                return
            }
            print("Successfully saved post to DB")
            self.dismiss(animated: true, completion: nil)
            
            let name = NSNotification.Name("Update Posts")
            NotificationCenter.default.post(name: name, object: nil)
            
        }
        
    }
    
    @objc func handleShare() {
        guard let image = selectedImage else { return }
        guard let bookName = bookTitleTextField.text, bookName.count>0 else {
            Loaf("Please enter a book title", state: .error, sender: self).show()
            return}
        guard let authorName = authorNameTextField.text, authorName.count>0 else {
            Loaf("Please enter an author name", state: .error, sender: self).show()
            return}
        guard let bookReview = bookReviewView.text, bookReview.count>0 else {
            Loaf("Please enter your review", state: .error, sender: self).show()
            return}
        
        guard let uploadData = image.jpegData(compressionQuality: 0.5) else { return }
        
        navigationItem.rightBarButtonItem?.isEnabled = false
        
        let filename = NSUUID().uuidString
       
        let storageRef = Storage.storage().reference().child("posts").child(filename)
        storageRef.putData(uploadData, metadata: nil) { (metadata, err) in
            
            if let err = err {
                self.navigationItem.rightBarButtonItem?.isEnabled = true
                print("Failed to upload post image:", err)
                return
            }
            
            storageRef.downloadURL(completion: { (downloadURL, err) in
                if let err = err {
                    print("Failed to fetch downloadURL:", err)
                    return
                }
                guard let imageUrl = downloadURL?.absoluteString else { return }
                
                print("Successfully uploaded post image:", imageUrl)
                
                self.saveToDatabaseWithImageURL(imageUrl)
                
            })
        }
    }
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
}
