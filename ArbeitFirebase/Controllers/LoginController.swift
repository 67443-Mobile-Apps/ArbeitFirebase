// Created for ArbeitFirebase on 10/19/20 
// Using Swift 5.0 
// Running on macOS 11.0
// Qapla'
//

import Foundation
import UIKit
import Firebase

class LoginController: UIViewController {
  
  // MARK: Constants
  let loginToTaskList = "LoginToTaskList"
  
  // MARK: Outlets
  @IBOutlet weak var textFieldLoginEmail: UITextField!
  @IBOutlet weak var textFieldLoginPassword: UITextField!
  
//  override var preferredStatusBarStyle: UIStatusBarStyle {
//    return .lightContent
//  }
  
  // MARK: UIViewController Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    
    Auth.auth().addStateDidChangeListener() { auth, user in
      if user != nil {
        self.performSegue(withIdentifier: self.loginToTaskList, sender: nil)
        self.textFieldLoginEmail.text = nil
        self.textFieldLoginPassword.text = nil
      }
    }
  }
  
  // MARK: Actions
  @IBAction func didTouchLogin(_ sender: AnyObject) {
    
    // Initially, want to get in without actually logging in...
    //  performSegue(withIdentifier: loginToTaskList, sender: nil)
    
    // When time to actually log in...
    guard
      let email = textFieldLoginEmail.text,
      let password = textFieldLoginPassword.text,
      email.count > 0,
      password.count > 0
      else {
        return
    }

    Auth.auth().signIn(withEmail: email, password: password) { user, error in
      if let error = error, user == nil {
        let alert = UIAlertController(title: "Sign In Failed",
                                      message: error.localizedDescription,
                                      preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "OK", style: .default))

        self.present(alert, animated: true, completion: nil)
      }
    }
    
    
  }
  
  @IBAction func didTouchSignUp(_ sender: AnyObject) {
    let alert = UIAlertController(title: "Register",
                                  message: "Register",
                                  preferredStyle: .alert)
    
    let saveAction = UIAlertAction(title: "Save", style: .default) { _ in
      
      let emailField = alert.textFields![0]
      let passwordField = alert.textFields![1]
      
      Auth.auth().createUser(withEmail: emailField.text!, password: passwordField.text!) { user, error in
        if error != nil {
          print(error?.localizedDescription)
          if let errorCode = AuthErrorCode(rawValue: error!._code) {
            switch errorCode {
            case .weakPassword:
              print("Please provide a strong password")
            default:
              print("Time to panic")
            }
          }
        }
        else {
          Auth.auth().signIn(withEmail: self.textFieldLoginEmail.text!,
                             password: self.textFieldLoginPassword.text!)
        }

      }
    }
    
    let cancelAction = UIAlertAction(title: "Cancel",
                                     style: .cancel)
    
    alert.addTextField { textEmail in
      textEmail.placeholder = "Enter your email"
    }
    
    alert.addTextField { textPassword in
      textPassword.isSecureTextEntry = true
      textPassword.placeholder = "Enter your password"
    }
    
    alert.addAction(saveAction)
    alert.addAction(cancelAction)
    
    present(alert, animated: true, completion: nil)
  }
}

extension LoginController: UITextFieldDelegate {
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    if textField == textFieldLoginEmail {
      textFieldLoginPassword.becomeFirstResponder()
    }
    if textField == textFieldLoginPassword {
      textField.resignFirstResponder()
    }
    return true
  }
}
