//
//  Post.swift
//  Bookstagram
//
//  Created by Vishaal Kumar on 6/24/20.
//  Copyright © 2020 Vishaal Kumar. All rights reserved.
//

import Foundation

struct Post {
    var id: String?
    
    let user: User
    let imageURL: String
    var bookDetails = [String: Any]()
    let creationDate: Date
    var isLiked: Bool = false
    init(user: User, dictionary: [String: Any]) {
        self.user = user
        self.imageURL = dictionary["imageURL"] as? String ?? ""
        self.bookDetails["bookName"] = dictionary["bookName"] as? String ?? ""
        self.bookDetails["authorName"] = dictionary["authorName"] as? String ?? ""
        self.bookDetails["bookRating"] = dictionary["bookRating"] as? Double ?? 0.0
        self.bookDetails["bookReview"] = dictionary["bookReview"] as? String ?? ""
        
        let secondsFrom1970 = dictionary["creationDate"] as? Double ?? 0
        self.creationDate = Date(timeIntervalSince1970: secondsFrom1970)
    }
}


