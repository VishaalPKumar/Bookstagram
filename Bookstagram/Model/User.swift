//
//  User.swift
//  Bookstagram
//
//  Created by Vishaal Kumar on 6/19/20.
//  Copyright © 2020 Vishaal Kumar. All rights reserved.
//

import Foundation

struct User {
    let uid: String
    let username: String
    let profileImageURL: String
    
    init(_ uid: String, _ userDetails: [String: Any]) {
        self.username = userDetails["username"] as? String ?? ""
        self.profileImageURL = userDetails["profileImageURL"] as? String ?? ""
        self.uid = uid
    }
}
