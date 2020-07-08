//
//  ViewController.swift
//  Bookstagram
//
//  Created by Vishaal Kumar on 6/17/20.
//  Copyright © 2020 Vishaal Kumar. All rights reserved.
//

import UIKit
import Firebase
import Loaf
import TextFieldEffects

class SignUpViewController: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    
   let plusPhotoButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "person"), for: .normal)
        button.layer.borderColor = UIColor(named: "Text Color")?.cgColor
        button.layer.borderWidth = 1
        button.tintColor = UIColor(named: "Button Color")
        button.addTarget(self, action: #selector(handlePlusPhoto), for: .touchUpInside)
        return button
    }()
    
    @objc func handlePlusPhoto() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
        
        present(imagePickerController, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let editedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            plusPhotoButton.setImage(editedImage.withRenderingMode(.alwaysOriginal), for: .normal)
        } else if let originalImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            plusPhotoButton.setImage(originalImage.withRenderingMode(.alwaysOriginal), for: .normal)
        }
        
        plusPhotoButton.layer.cornerRadius = plusPhotoButton.frame.width/2
        plusPhotoButton.layer.masksToBounds = true
        plusPhotoButton.layer.borderColor = UIColor.black.cgColor
        plusPhotoButton.layer.borderWidth = 3
        
        dismiss(animated: true, completion: nil)
    }
    
    let emailTextField: MadokaTextField = {
        let tf = MadokaTextField(frame: CGRect())
        tf.placeholderColor = UIColor(named: "Text Color")!
        tf.textColor = UIColor(named: "Button Color")
        tf.placeholder = "Email"
        tf.font = UIFont(name: "HelveticaNeue-Light", size: 20)
        tf.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
        
        return tf
    }()
    
    @objc func textFieldChanged() {
        if isFormValid() {
            enableButton()
        } else {
            disableButton()
        }
    }
    

    
    let usernameTextField: MadokaTextField = {
        let tf = MadokaTextField(frame: CGRect())
        tf.placeholderColor = UIColor(named: "Text Color")!
        tf.textColor = UIColor(named: "Button Color")
        tf.placeholder = "Username"
        tf.font = UIFont(name: "HelveticaNeue-Light", size: 20)
        tf.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
        
        return tf
    }()
    
    let passwordTextField: MadokaTextField = {
        let tf = MadokaTextField(frame: CGRect())
        tf.placeholderColor = UIColor(named: "Text Color")!
        tf.textColor = UIColor(named: "Button Color")
        tf.placeholder = "Password"
        tf.font = UIFont(name: "HelveticaNeue-Light", size: 20)
        tf.isSecureTextEntry = true
        tf.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
        return tf
    }()
    

    
    let signupButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Sign Up", for: .normal)
        button.layer.cornerRadius = 5
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.addTarget(self, action: #selector(handleSignUp), for: .touchUpInside)
        return button
    }()
    
    @objc func handleSignUp() {
        guard let email = emailTextField.text, !email.isEmpty else {
            
            return }
        guard let username = usernameTextField.text, !username.isEmpty else { return }
        guard let password = passwordTextField.text, !password.isEmpty else { return }
        
        Auth.auth().createUser(withEmail: email, password: password, completion: { (user, error: Error?) in
            
            if let err = error {
                print("Failed to create user:", err)
                return
            }
            
            print("Successfully created user:", user?.user.uid ?? "")
            
            guard let image = self.plusPhotoButton.imageView?.image else { return }
            
            guard let uploadData = image.jpegData(compressionQuality: 0.3) else { return }
            
            let filename = NSUUID().uuidString
            
            let storageRef = Storage.storage().reference().child("profile_images").child(filename)
            storageRef.putData(uploadData, metadata: nil, completion: { (metadata, err) in
                
                if let err = err {
                    print("Failed to upload profile image:", err)
                    return
                }
                
                // Firebase 5 Update: Must now retrieve downloadURL
                storageRef.downloadURL(completion: { (downloadURL, err) in
                    guard let profileImageURL = downloadURL?.absoluteString else { return }
                    
                    print("Successfully uploaded profile image:", profileImageURL)
                    
                    guard let uid = user?.user.uid else { return }
                    
                    let dictionaryValues = ["username": username, "profileImageURL": profileImageURL]
                    let values = [uid: dictionaryValues]
                    
                    Database.database().reference().child("users").updateChildValues(values, withCompletionBlock: { (err, ref) in
                        
                        if let err = err {
                            print("Failed to save user info into db:", err)
                            return
                        }
                        
                        print("Successfully saved user info to db")
                        
                        guard let mainTabBarController = UIApplication.shared.keyWindow?.rootViewController as? MainTabBarController else { return }
                        
                        mainTabBarController.setupViewControllers()
                        
                        self.dismiss(animated: true, completion: nil)
                        
                    })
                })
            })
        })
    }
    
    let alreadyHaveAccountButton: UIButton = {
        let button = UIButton(type: .system)
        
        let attributedTitle = NSMutableAttributedString(string: "Already have an account?  ", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        
        attributedTitle.append(NSAttributedString(string: "Sign In", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor(named: "Text Color")!
            ]))
        
        button.setAttributedTitle(attributedTitle, for: .normal)
        
        button.addTarget(self, action: #selector(handleAlreadyHaveAccount), for: .touchUpInside)
        return button
    }()
    
    @objc func handleAlreadyHaveAccount() {
        _ = navigationController?.popViewController(animated: true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(alreadyHaveAccountButton)
        alreadyHaveAccountButton.anchor(top: nil, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 50)
        
        view.backgroundColor = UIColor(named: "Background Color")
        
        view.addSubview(plusPhotoButton)
        
        plusPhotoButton.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: nil, bottom: nil, right: nil, paddingTop: 40, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 140, height: 140)
        
        plusPhotoButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        setupInputFields()
        disableButton()
        
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing))
        view.addGestureRecognizer(tap)
    }
    
    fileprivate func setupInputFields() {
        let stackView = UIStackView(arrangedSubviews: [emailTextField, usernameTextField, passwordTextField, signupButton])
        stackView.distribution = .fillEqually
        stackView.axis = .vertical
        stackView.spacing = 10
        
        view.addSubview(stackView)
        
        stackView.anchor(top: plusPhotoButton.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 30, paddingLeft: 40, paddingBottom: 0, paddingRight: 40, width: 0, height: 250)
    }

    
    //MARK: - Validation Methods
    
    func enableButton() {
        signupButton.isEnabled = true
        signupButton.layer.cornerRadius = 10
        signupButton.layer.backgroundColor = UIColor(named: "Button Color")?.cgColor
        signupButton.setTitleColor(UIColor(named: "Background Color"), for: .normal)
    }
    
    func disableButton() {
        signupButton.isEnabled = false
        signupButton.layer.cornerRadius = 10
        signupButton.layer.backgroundColor = .none
        signupButton.layer.borderColor = UIColor(named: "Button Color")?.cgColor
        signupButton.layer.borderWidth = 1
        signupButton.setTitleColor(UIColor(named: "Button Color"), for: .disabled)
    }
    
    func isFormValid() -> Bool {
        if isValidEmail(emailTextField.text!) && isValidPassword(passwordTextField.text!) && isValidUsername(usernameTextField.text!) {
            return true
        } else {
            return false
        }
    }
    
    func isValidUsername(_ username: String) -> Bool {
        if (username.count > 0) {
            return true
        } else {
            return false
        }
    }
    
    func isValidPassword(_ password: String) -> Bool {
        
        if (password.rangeOfCharacter(from: CharacterSet.uppercaseLetters) == nil) {
            return false
        }
        if (password.rangeOfCharacter(from: CharacterSet.lowercaseLetters) == nil) {
            return false
        }
        if (password.rangeOfCharacter(from: CharacterSet.decimalDigits) == nil) {
            return false
        }
        if password.count < 8 {
            return false
        }
        return true
    }
    
    func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    //MARK: - Design Methods
    
    func designButton() {
        signupButton.layer.cornerRadius = 10
        signupButton.layer.backgroundColor = .none
        signupButton.layer.borderColor = UIColor(named: "Button Color")?.cgColor
        signupButton.layer.borderWidth = 1
        signupButton.setTitleColor(UIColor(named: "Button Color"), for: .disabled)
        
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
}






