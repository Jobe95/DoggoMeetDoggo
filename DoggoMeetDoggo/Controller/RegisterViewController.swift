//
//  RegisterViewController.swift
//  DoggoMeetDoggo
//
//  Created by Jonatan Bengtsson on 2019-04-10.
//  Copyright © 2019 Jonatan Bengtsson. All rights reserved.
//

import UIKit
import Firebase

class RegisterViewController: UIViewController {
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    
    let db = Firestore.firestore()
    
    @IBOutlet weak var addPhoto: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    
    func createNewUser() {

        Auth.auth().createUser(withEmail: emailTextField.text!, password: passwordTextField.text!) { user, error in
            
            if error != nil {
                // Något fel har hänt
                print("Cannot create user \(error!)")
            } else {
                // Registrera användare fungerar
                print("Create user works fine")
                
                let uid = Auth.auth().currentUser?.uid
                
                self.db.collection("users").document(uid!).setData([
                    "firstname": self.firstNameTextField.text!,
                    "lastname": self.lastNameTextField.text!,
                    "userID": uid,
                    "email": self.emailTextField.text!,
                ]) { err in
                    if let err = err {
                        print("Error writing document: \(err)")
                    } else {
                        print("Document successfully written!")
                    }
                }
            }
        }
    
    }
    
    @IBAction func addPhotoButtonPressed(_ sender: UIButton) {
        
        
    }
    
    
    @IBAction func registerButtonPressed(_ sender: UIButton) {
        
        createNewUser()
        
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
