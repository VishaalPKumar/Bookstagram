//
//  UserSearchController.swift
//  Bookstagram
//
//  Created by Vishaal Kumar on 6/27/20.
//  Copyright © 2020 Vishaal Kumar. All rights reserved.
//

import UIKit
import Firebase

private let reuseIdentifier = "Cell"

class UserSearchController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    var allUsers = [User]()
    var filteredUsers = [User]()
    var selectedUser: User?
    
    var databaseRef: DatabaseReference!
    var storageRef: StorageReference!
    
    lazy var searchBar: UISearchBar = {
        let sb = UISearchBar()
        sb.placeholder = "Enter username"
        sb.delegate = self
        return sb
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.backgroundColor = UIColor(named: "Background Color")
        //Firebase Database
        databaseRef = Database.database().reference()
        //Firebase Storage
        storageRef = Storage.storage().reference()
        
        guard let navBar = navigationController?.navigationBar else {return}

        navBar.addSubview(searchBar)
        searchBar.anchor(top: navBar.topAnchor, left: navBar.leftAnchor, bottom: navBar.bottomAnchor, right: navBar.rightAnchor, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 8, width: 0, height: 0)
        // Register cell classes
       
        self.collectionView!.register(UserSearchCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        
        collectionView.alwaysBounceVertical = true
        collectionView.keyboardDismissMode = .onDrag
        
        fetchUsers()

    }
    
    override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            searchBar.isHidden = false
    }
    

    
    fileprivate func fetchUsers() {
        let usersRef = databaseRef.child("users")
        usersRef.observeSingleEvent(of: .value, with: { (snapshot) in
            guard let dictionaries = snapshot.value as? [String:Any] else {return}
            dictionaries.forEach { (key, value) in
                //Do not want to display currently logged in user in search page
                if key == Auth.auth().currentUser?.uid {
                    return
                }
                guard let userDictionary = value as? [String:Any] else {return}
                let user = User(key, userDictionary)
                self.allUsers.append(user)
            }
            
            self.allUsers.sort { (u1, u2) -> Bool in
                return u1.username.compare(u2.username) == .orderedAscending
            }
            
            self.filteredUsers = self.allUsers
            self.collectionView.reloadData()
            
        }) { (error) in
            print("Could not fetch users from Firebase: \(error)")
        }
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        searchBar.isHidden = true
        searchBar.resignFirstResponder()
        
        let user = filteredUsers[indexPath.item]
        print(user.username)
        
        let userProfileController = ProfileViewController(collectionViewLayout: UICollectionViewFlowLayout())
        userProfileController.userId = user.uid
        navigationController?.pushViewController(userProfileController, animated: true)
   
    }
    


    // MARK:- UICollectionViewDataSource


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filteredUsers.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! UserSearchCell
        
        cell.user = filteredUsers[indexPath.item]
        
        
        return cell
    }

    // MARK:- UICollectionViewDelegateFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: 66)
    }
}

//MARK: - UISearchBarDelegate Methods

extension UserSearchController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchText.isEmpty {
            filteredUsers = allUsers
        } else {
            self.filteredUsers = self.allUsers.filter { (user) -> Bool in
                return user.username.lowercased().contains(searchText.lowercased())
            }
        }

        self.collectionView.reloadData()
    }
    
}
