//
//  ProfileViewController.swift
//  DoggoMeetDoggo
//
//  Created by Jonatan Bengtsson on 2019-04-10.
//  Copyright © 2019 Jonatan Bengtsson. All rights reserved.
//

import UIKit
import Firebase

class ProfileViewController: UIViewController, UITextViewDelegate {
    
    @IBOutlet weak var profileImageView: UIImageView!
    
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var dogInfoLabel: UILabel!
    
    @IBOutlet weak var aboutUserLabel: UILabel!
    @IBOutlet weak var aboutUserTextView: UITextView!
    
    @IBOutlet weak var aboutDogLabel: UILabel!
    @IBOutlet weak var aboutDogTextView: UITextView!
    
    
    let db = Firestore.firestore()
    let currentUID = Auth.auth().currentUser?.uid
    var user = [Users]()

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Din profil"
        if Auth.auth().currentUser != nil {
            // User is signed in.
            loadCurrentUser()
        } else {
            // No user is signed in.
            performSegue(withIdentifier: "goToRoot", sender: self)
        }
        
        
        aboutUserTextView.delegate = self
        aboutDogTextView.delegate = self

        // Do any additional setup after loading the view.
    }
    
    func loadCurrentUser() {
        
        db.collection("users").document(currentUID!).getDocument {
            (snapshot, error) in
            if let error = error {
                print("Error getting documents: \(error)")
            }
            else {
                if let document = snapshot {
                    
                        var user = Users()
                        
                        user.firstName = document["firstname"] as? String
                        user.lastName = document["lastname"] as? String
                        user.email = document["email"] as? String
                        user.uid = document["userID"] as? String
                        user.aboutUser = document["aboutUser"] as? String
                        user.aboutDog = document["aboutUserDog"] as? String
                        self.user.append(user)
                        print("Printar inuti closure")
                        print(user)
                        self.loadLabels()
                }
            }
        }
    }
    
    func loadLabels() {
        print("Printar user array")
        print(user)
        userNameLabel.text = "\(user[0].firstName ?? "Förnamn") \(user[0].lastName ?? "Efternamn")"
        aboutUserLabel.text = "Om \(user[0].firstName ?? "Användarnamn")"
        aboutUserTextView.text = "\(user[0].aboutUser ?? "Info om dig själv")"
        aboutDogTextView.text = "\(user[0].aboutDog ?? "Info om din/dina hundar")"
        
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        
        let userRef = db.collection("users").document(currentUID!)
        
        // Lägger till aboutUser och aboutUserDog fälten till currentUser på DB
        userRef.updateData([
            "aboutUser": aboutUserTextView.text ?? "Info om dig själv",
            "aboutUserDog": aboutDogTextView.text ?? "Info om din/dina hundar"
        ]) { err in
            if let err = err {
                print("Error updating document: \(err)")
            } else {
                print("Document successfully updated")
            }
        }
        loadLabels()
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
