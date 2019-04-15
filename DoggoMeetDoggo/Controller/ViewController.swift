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
        let handle = Auth.auth()
        // Do any additional setup after loading the view, typically from a nib.
        navigationItem.title = "Välkommen"
    }
    
//    override func viewWillAppear(_ animated: Bool) {
//        handle.addStateDidChangeListener { (auth, user) in
////            For each of your app's views that need information about the signed-in user, attach a listener to the FIRAuth object. This listener gets called whenever the user's sign-in state changes.
////
////            Attach the listener in the view controller's viewWillAppear method:
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

