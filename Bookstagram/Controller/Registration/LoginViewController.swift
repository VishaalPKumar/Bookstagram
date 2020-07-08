//
//  LoginViewController.swift
//  Bookstagram
//
//  Created by Vishaal Kumar on 6/20/20.
//  Copyright © 2020 Vishaal Kumar. All rights reserved.
//

import UIKit
import Firebase
import TextFieldEffects
import Loaf

class LoginViewController: UIViewController {
    
    let logoContainerView: UIView = {
        let view = UIView()
        
        let logoImageView = UIImageView(image: #imageLiteral(resourceName: "bookstagram"))
        logoImageView.contentMode = .scaleAspectFill
        
        view.addSubview(logoImageView)
        logoImageView.anchor(top: nil, left: nil, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 300, height: 300)
        logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        logoImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
        return view
    }()
    
    let emailTextField: MadokaTextField = {
        let tf = MadokaTextField(frame: CGRect())
        tf.placeholderColor = UIColor(named: "Text Color")!
        tf.textColor = UIColor(named: "Button Color")
        tf.placeholder = "Email"
        tf.keyboardType = .emailAddress
        tf.textContentType = .emailAddress
        tf.font = UIFont(name: "HelveticaNeue-Light", size: 20)
        tf.addTarget(self, action: #selector(emailTextFieldChanged), for: .editingChanged)
        
        return tf
    }()
    
    let passwordTextField: MadokaTextField = {
        let tf = MadokaTextField(frame: CGRect())
        tf.placeholderColor = UIColor(named: "Text Color")!
        tf.textColor = UIColor(named: "Button Color")
        tf.placeholder = "Password"
        tf.font = UIFont(name: "HelveticaNeue-Light", size: 20)
        tf.isSecureTextEntry = true
        tf.addTarget(self, action: #selector(passwordTextFieldChanged), for: .editingChanged)
        return tf
    }()
    

    
    let loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Login", for: .normal)
        
        button.layer.cornerRadius = 5
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.setTitleColor(.white, for: .normal)
        
        button.addTarget(self, action: #selector(loginButtonPressed), for: .touchUpInside)
        
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(logoContainerView)
        logoContainerView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 40, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 300)
        
        navigationController?.isNavigationBarHidden = true
        
        view.backgroundColor = UIColor(named: "Background Color")
        
        view.addSubview(dontHaveAccountButton)
        dontHaveAccountButton.anchor(top: nil, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 50)
        
        setupInputFields()

        disableButton()
        designButton()
        
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing))
        view.addGestureRecognizer(tap)
        
    }
    
    fileprivate func setupInputFields() {
         let stackView = UIStackView(arrangedSubviews: [emailTextField, passwordTextField, loginButton])
         
         stackView.axis = .vertical
         stackView.spacing = 10
         stackView.distribution = .fillEqually
         
         view.addSubview(stackView)
         stackView.anchor(top: logoContainerView.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 40, paddingLeft: 40, paddingBottom: 0, paddingRight: 40, width: 0, height: 200)
     }
    
    @objc func emailTextFieldChanged() {
        if isFormValid() {
            enableButton()
        } else {
            disableButton()
        }
    }
    
    @objc func passwordTextFieldChanged() {
        if isFormValid() {
            enableButton()
        } else {
            disableButton()
        }
    }
    
    @objc func loginButtonPressed() {
        guard let email = emailTextField.text, isFormValid() else{ return }
        guard let password = passwordTextField.text, isFormValid() else{ return }
        Auth.auth().signIn(withEmail: email, password: password) { (dataResult, error) in
            if let err = error {
                print("Failed to login user: \(err)")
                Loaf("Invalid Login Details", state: .error, sender: self).show()
                return
            }
            guard let mainTabBarController = UIApplication.shared.keyWindow?.rootViewController as? MainTabBarController else { return }
            
            mainTabBarController.setupViewControllers()
            
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    let dontHaveAccountButton: UIButton = {
        let button = UIButton(type: .system)
        
        let attributedTitle = NSMutableAttributedString(string: "Don't have an account?  ", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        
        attributedTitle.append(NSAttributedString(string: "Sign Up", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor(named: "Text Color")!
            ]))
        
        button.setAttributedTitle(attributedTitle, for: .normal)
        
        button.addTarget(self, action: #selector(handleShowSignUp), for: .touchUpInside)
        return button
    }()
    
    @objc func handleShowSignUp() {
        let signUpController = SignUpViewController()
        navigationController?.pushViewController(signUpController, animated: true)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    //MARK: - Design Methods
    
    func designButton() {
        loginButton.layer.cornerRadius = 10
        loginButton.layer.backgroundColor = .none
        loginButton.layer.borderColor = UIColor(named: "Button Color")?.cgColor
        loginButton.layer.borderWidth = 1
        loginButton.setTitleColor(UIColor(named: "Button Color"), for: .disabled)
        
    }
    
    //MARK: - Validation Methods
    
    func enableButton() {
        loginButton.isEnabled = true
        loginButton.layer.cornerRadius = 10
        loginButton.layer.backgroundColor = UIColor(named: "Button Color")?.cgColor
        loginButton.setTitleColor(UIColor(named: "Background Color"), for: .normal)
    }
    
    func disableButton() {
        loginButton.isEnabled = false
        loginButton.layer.cornerRadius = 10
        loginButton.layer.backgroundColor = .none
        loginButton.layer.borderColor = UIColor(named: "Button Color")?.cgColor
        loginButton.layer.borderWidth = 1
        loginButton.setTitleColor(UIColor(named: "Button Color"), for: .disabled)
    }
    
    func isFormValid() -> Bool {
        if isValidEmail(emailTextField.text!) && isValidPassword(passwordTextField.text!) {
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
    
}
