//
//  ViewController.swift
//  DoggoMeetDoggo
//
//  Created by Jonatan Bengtsson on 2019-04-10.
//  Copyright © 2019 Jonatan Bengtsson. All rights reserved.
//

import UIKit
import Firebase

class ViewController: UIViewController {
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        navigationItem.title = "Välkommen"
        
        
//        if Auth.auth().currentUser != nil {
//            // User is signed in.
//            // ...
//
//            print("\((Auth.auth().currentUser?.email))")
//
//            performSegue(withIdentifier: "goToMain", sender: self)
//        } else {
//            // No user is signed in.
//            // ...
//        }
        
        
    }
    
//    override func viewWillAppear(_ animated: Bool) {
//        
//        }
//    }
//    
//    override func viewWillDisappear(_ animated: Bool) {
//        handle.removeStateDidChangeListener(handle)
//    }
    
    @IBAction func loginButtonPressed(_ sender: UIButton) {
    }
    @IBAction func registerButtonpressed(_ sender: UIButton) {
    }
    

}

