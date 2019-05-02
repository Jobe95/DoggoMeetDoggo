//
//  LoginViewController.swift
//  DoggoMeetDoggo
//
//  Created by Jonatan Bengtsson on 2019-04-10.
//  Copyright © 2019 Jonatan Bengtsson. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: UIViewController {
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var loginButtonOutlet: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    
    }
    @IBAction func loginButtonPressed(_ sender: UIButton) {
        
        loginButtonOutlet.isEnabled = false
        
        Auth.auth().signIn(withEmail: emailTextField.text!, password: passwordTextField.text!) {
            (user, error) in
            if error != nil {
                print(error!)
            }
            else {
                if Auth.auth().currentUser != nil {
                    // User is signed in.
                    print("Login successful!")
                    self.performSegue(withIdentifier: "goToApp", sender: self)
                } else {
                    // No user is signed in.
                    print("Something went wrong, user is not signed in!")
                }
            }
            self.loginButtonOutlet.isEnabled = true
        }
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
