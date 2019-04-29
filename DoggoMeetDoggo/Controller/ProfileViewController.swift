//
//  ProfileViewController.swift
//  DoggoMeetDoggo
//
//  Created by Jonatan Bengtsson on 2019-04-10.
//  Copyright © 2019 Jonatan Bengtsson. All rights reserved.
//

import UIKit
import Firebase
import Kingfisher

protocol ProfileViewControllerDelegate: AnyObject {
    func passBack(_ currentUser: Users)
}

class ProfileViewController: UIViewController, UITextViewDelegate {
    
    @IBOutlet var backgroundView: UIView!
    
    @IBOutlet weak var profileImageView: UIImageView!
    
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var dogInfoLabel: UILabel!
    
    @IBOutlet weak var aboutUserLabel: UILabel!
    @IBOutlet weak var aboutUserTextView: UITextView!
    
    @IBOutlet weak var aboutDogLabel: UILabel!
    @IBOutlet weak var aboutDogTextView: UITextView!
    
    
    let db = Firestore.firestore()
    let currentUID = Auth.auth().currentUser?.uid
    var currentUser: Users?
    weak var delegate: ProfileViewControllerDelegate?
    

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Din profil"
        if Auth.auth().currentUser != nil {
            
            loadLabels()
        } else {
            // No user is signed in.
            self.navigationController?.popToRootViewController(animated: true)
        }
        
        // Set the tapGesture here:
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(viewTapped))
        backgroundView.addGestureRecognizer(tapGesture)
        
        aboutUserTextView.delegate = self
        aboutDogTextView.delegate = self

        // Do any additional setup after loading the view.
    }
    
    // Declare tableViewTapped here:
    @objc func viewTapped() {
        aboutUserTextView.endEditing(true)
        aboutDogTextView.endEditing(true)
        loadLabels()
    }
    
    func loadLabels() {
        print("Printar user")
        print(currentUser)
        
        let url = URL(string: currentUser?.photoURL ?? "No pic")
        
        userNameLabel.text = "\(currentUser?.firstName ?? "Förnamn") \(currentUser?.lastName ?? "Efternamn")"
        aboutUserLabel.text = "Om \(currentUser?.firstName ?? "Användarnamn")"
        aboutUserTextView.text = "\(currentUser?.aboutUser ?? "Info om dig själv")"
        aboutDogTextView.text = "\(currentUser?.aboutDog ?? "Info om din/dina hundar")"
        profileImageView.kf.setImage(with: url)
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        
        let userRef = db.collection("users").document(currentUID!)
        
        currentUser?.aboutUser = aboutUserTextView.text
        currentUser?.aboutDog = aboutDogTextView.text
        
        // Lägger till aboutUser och aboutUserDog fälten till currentUser på DB
        userRef.updateData([
            "aboutUser": currentUser?.aboutUser as Any,
            "aboutUserDog": currentUser?.aboutDog as Any
        ]) { err in
            if let err = err {
                print("Error updating document: \(err)")
            } else {
                print("Document successfully updated")
            }
        }
        delegate?.passBack(currentUser!)
        loadLabels()
    }
    
    @IBAction func logoutButtonPressed(_ sender: UIBarButtonItem) {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
        } catch let signOutError as NSError {
            print ("Error signing out: \(signOutError)")
        }
        
        self.navigationController?.popToRootViewController(animated: true)
        
    }
    
    //MARK: - Delegate methods
    
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if let mainVC = segue.destination as? MainViewController {
            mainVC.currentUser = currentUser!
        }
    }
}
