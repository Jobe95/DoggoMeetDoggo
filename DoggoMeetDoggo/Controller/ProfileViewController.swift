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

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Din profil"
        loadCurrentUser()
        
        aboutUserTextView.delegate = self
        aboutDogTextView.delegate = self

        // Do any additional setup after loading the view.
    }
    
    func loadCurrentUser() {
        
        
        
        db.collection("users").whereField("userID", isEqualTo: currentUID!).getDocuments {
            (snapshot, error) in
            if let error = error {
                print("Error getting documents: \(error)")
            }
            else {
                for document in snapshot!.documents {
                    //print("\(document.documentID) => \(document.data())")
                    
                    if let dictionary = document.data() as? [String : String] {

                        var user = Users()
                        user.firstName = dictionary["firstname"]
                        user.lastName = dictionary["lastname"]
                        user.email = dictionary["email"]
                        user.uid = dictionary["userID"]
                        user.aboutUser = dictionary["aboutUser"]
                        user.aboutDog = dictionary["aboutUserDog"]
                        self.loadLabels(user: user)
                        
                    }
                }
            }
        }
    }
    
    func loadLabels(user: Users) {
        userNameLabel.text = "\(user.firstName!) \(user.lastName!)"
        aboutUserLabel.text = "Om \(user.firstName!)"
        aboutUserTextView.text = "\(user.aboutUser ?? "Info om dig själv")"
        aboutDogTextView.text = "\(user.aboutDog ?? "Info om din/dina hundar")"
        
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        
        let userRef = db.collection("users").document(currentUID!)
        
        // Set the "capital" field of the city 'DC'
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
