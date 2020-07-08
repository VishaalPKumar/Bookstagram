//
//  MainTabBarController.swift
//  Bookstagram
//
//  Created by Vishaal Kumar on 6/19/20.
//  Copyright © 2020 Vishaal Kumar. All rights reserved.
//

import UIKit
import Firebase

class MainTabBarController: UITabBarController, UITabBarControllerDelegate {
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        
        let index = viewControllers?.firstIndex(of: viewController)
        if index == 2 {
            
            let layout = UICollectionViewFlowLayout()
            let bookSelectorController = BookSelectorViewController(collectionViewLayout: layout)
            let navController = UINavigationController(rootViewController: bookSelectorController)
            navController.modalPresentationStyle = .fullScreen
            present(navController, animated: true, completion: nil)
            
            return false
        }
        
        return true
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.delegate = self

        self.tabBar.barTintColor = UIColor(named: "Background Color")
        
        if Auth.auth().currentUser == nil {
            //show if not logged in
            DispatchQueue.main.async {
              let loginController = LoginViewController()
               let navController = UINavigationController(rootViewController: loginController)
                navController.modalPresentationStyle = .fullScreen
               self.present(navController, animated: true, completion: nil)
            }
            
            return
        }
        
        setupViewControllers()
    }
    

    
    func setupViewControllers() {
        //home
        let homeNavController = templateNavController(unselectedImage: UIImage(systemName: "house")!, selectedImage: UIImage(systemName: "house.fill")!, rootViewController: HomeCollectionViewController(collectionViewLayout: UICollectionViewFlowLayout()))
        
        //search
        let searchNavController = templateNavController(unselectedImage: UIImage(systemName: "magnifyingglass.circle")!, selectedImage: UIImage(systemName: "magnifyingglass.circle.fill")!, rootViewController: UserSearchController(collectionViewLayout: UICollectionViewFlowLayout()))
        
        let plusNavController = templateNavController(unselectedImage: UIImage(systemName: "plus.app")!, selectedImage: UIImage(systemName: "plus.app.fill")!)
        
        let likeNavController = templateNavController(unselectedImage: UIImage(systemName: "heart")!, selectedImage: UIImage(systemName: "heart.fill")!)
        
        //user profile
        let layout = UICollectionViewFlowLayout()
        let userProfileController = ProfileViewController(collectionViewLayout: layout)
        
        let userProfileNavController = UINavigationController(rootViewController: userProfileController)
        
        userProfileNavController.tabBarItem.image = UIImage(systemName: "person")!
        userProfileNavController.tabBarItem.selectedImage = UIImage(systemName: "person.fill")!
        
        tabBar.tintColor = UIColor(named: "Button Color")
        
        viewControllers = [homeNavController,
                           searchNavController,
                           plusNavController,
                           likeNavController,
                           userProfileNavController]
        
        //modify tab bar item insets
        guard let items = tabBar.items else { return }
        
        for item in items {
            item.imageInsets = UIEdgeInsets(top: 4, left: 0, bottom: -4, right: 0)
        }
    }
    
    fileprivate func templateNavController(unselectedImage: UIImage, selectedImage: UIImage, rootViewController: UIViewController = UIViewController()) -> UINavigationController {
        let viewController = rootViewController
        let navController = UINavigationController(rootViewController: viewController)
        navController.tabBarItem.image = unselectedImage
        navController.tabBarItem.selectedImage = selectedImage
        return navController
    }
}

