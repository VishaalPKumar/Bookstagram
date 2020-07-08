//
//  HomeCollectionViewController.swift
//  Bookstagram
//
//  Created by Vishaal Kumar on 6/25/20.
//  Copyright © 2020 Vishaal Kumar. All rights reserved.
//

import UIKit
import Firebase


class HomeCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout, HomePostCellDelegate {

    var databaseRef: DatabaseReference!
    var storageRef: StorageReference!
    var posts = [Post]()
    let cellId = "cellId"
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let name = NSNotification.Name("Update Posts")
        NotificationCenter.default.addObserver(self, selector: #selector(handleUpdateFeed), name: name, object: nil)
        collectionView.backgroundColor = UIColor(named: "Background Color")
  
        //Firebase Database
        databaseRef = Database.database().reference()
        //Firebase Storage
        storageRef = Storage.storage().reference()
        
        // Register cell classes
        collectionView?.register(HomePostCell.self, forCellWithReuseIdentifier: cellId)
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        collectionView?.refreshControl = refreshControl
        fetchAllPosts()
    }
    
   @objc func handleUpdateFeed() {
        handleRefresh()
    }
    
    @objc func handleRefresh() {
        print("Handling refresh..")
        posts.removeAll()
        fetchAllPosts()
    }
    
    fileprivate func fetchAllPosts() {
        fetchPosts()
        fetchFollowingUserIds()
    }
    
    
    
     fileprivate func fetchFollowingUserIds() {
           guard let uid = Auth.auth().currentUser?.uid else { return }
           databaseRef.child("following").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
               
            self.collectionView.refreshControl?.endRefreshing()
               guard let userIdsDictionary = snapshot.value as? [String: Any] else { return }
               
               userIdsDictionary.forEach({ (key, value) in
                   Database.fetchUserWithUID(uid: key, completion: { (user) in
                       self.fetchPostsWithUser(user: user)
                   })
               })
               
           }) { (err) in
               print("Failed to fetch following user ids:", err)
           }
        
       }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let navBar = navigationController?.navigationBar else { fatalError("Navigation controller does not exist.")
        }
        self.navigationItem.title = "Bookstagram"
//        navBar.prefersLargeTitles = true
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.configureWithOpaqueBackground()
        navBarAppearance.titleTextAttributes = [.foregroundColor: UIColor(named: "Text Color")!]
        navBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor(named: "Text Color")!]
        navBarAppearance.backgroundColor = .white
        navBar.standardAppearance = navBarAppearance
        navBar.scrollEdgeAppearance = navBarAppearance
        navBar.tintColor = UIColor(named: "Text Color")
        
        setUpNavigationItems()
        handleRefresh()
    }
    
    func setUpNavigationItems() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "camera"), style: .plain, target: self, action: #selector(handleCamera))
    }
    
    @objc func handleCamera() {
        print("Show Camera")
        let cameraController = CameraController()
        cameraController.modalPresentationStyle = .fullScreen
        present(cameraController, animated: true, completion: nil)
    }
    
    fileprivate func fetchPosts() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        Database.fetchUserWithUID(uid: uid) { (user) in
            self.fetchPostsWithUser(user: user)
        }
    }
    
    fileprivate func fetchPostsWithUser(user: User) {
        let ref = databaseRef.child("posts").child(user.uid)
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            guard let dictionaries = snapshot.value as? [String: Any] else { return }
            
            dictionaries.forEach({ (key, value) in
                guard let dictionary = value as? [String: Any] else { return }
                
                var post = Post(user: user, dictionary: dictionary)
                post.id = key
                
                guard let uid = Auth.auth().currentUser?.uid else {return}
                
                self.databaseRef.child("likes").child(key).child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
                    print(snapshot)
                    if let value = snapshot.value as? Int, value == 1 {
                        post.isLiked = true
                    } else {
                        post.isLiked = false
                    }
                    self.posts.append(post)
                    self.posts.sort(by: { (p1, p2) -> Bool in
                                  return p1.creationDate.compare(p2.creationDate) == .orderedDescending
                              })
                    self.collectionView?.reloadData()
                }) { (error) in
                    print("Error in fetching liked status of post")
                }
            })
        }) { (err) in
            print("Failed to fetch posts:", err)
        }
    }
    
    // MARK:- UICollectionViewDataSource
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! HomePostCell
        
        // Configure the cell
        cell.post = posts[indexPath.item]
        
        cell.delegate = self
        
        return cell
    }
    
    // MARK:- UICollectionFlowViewDelegate
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        var height: CGFloat = 40 + 8 + 8 //username userprofileimageview
        height += view.frame.width
        height += 50
        height += 120
        
        return CGSize(width: view.frame.width, height: height)
    }
    
    func didTapComment(post: Post) {
        print("Message is coming from home controller..")
        print(post.bookDetails)
        let commentsController = CommentsController(collectionViewLayout: UICollectionViewFlowLayout())
        commentsController.post = post
        navigationController?.pushViewController(commentsController, animated: true)
        
    }
    func didLike(for cell: HomePostCell) {
        print("Post Liked")
        
        guard let indexPath = collectionView.indexPath(for: cell) else {return}
        var post = self.posts[indexPath.item]
        print(post.bookDetails)
        
        guard let postId = post.id else {return}
        guard let uid = Auth.auth().currentUser?.uid else {return}
        
        let values = [uid : post.isLiked == true ? 0 : 1]
        databaseRef.child("likes").child(postId).updateChildValues(values) { (error, _) in
            if let err = error {
                print("Error in storing post liked status in Firebase : \(err)")
            }
            print("Successfully liked photo and stored status in Firebase")
            post.isLiked = !post.isLiked
            
            self.posts[indexPath.item] = post
            self.collectionView.reloadItems(at: [indexPath])
        }
    }
    
    
}
