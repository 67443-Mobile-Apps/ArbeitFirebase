// Created for ArbeitFirebase on 10/19/20 
// Using Swift 5.0 
// Running on macOS 11.0
// Qapla'
//

import Foundation
import Firebase

struct User {
  
  let uid: String
  let email: String
  
  init(authData: Firebase.User) {
    uid = authData.uid
    email = authData.email!
  }
  
  init(uid: String, email: String) {
    self.uid = uid
    self.email = email
  }
}
