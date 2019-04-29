//
//  MainViewController.swift
//  DoggoMeetDoggo
//
//  Created by Jonatan Bengtsson on 2019-04-10.
//  Copyright © 2019 Jonatan Bengtsson. All rights reserved.
//

import UIKit
import Firebase
import Kingfisher

class MainViewController: UIViewController, ProfileViewControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var noButtonOutlet: UIButton!
    @IBOutlet weak var yesButtonOutlet: UIButton!
    
    let db = Firestore.firestore()
    let currentUID = Auth.auth().currentUser?.uid
    var allUsersArray = [Users]()
    var currentUserArray = [String]()
    
    var currentUser = Users()
    var user = Users()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Hitta vänner"
        
        checkIfUserIsFriends()
        loadAllUsersFromDB()
        

        // Do any additional setup after loading the view.
    }
    
    //MARK: - Load Methods
    func loadAllUsersFromDB() {
        db.collection("users").getDocuments { (snapshot, error) in
            if error != nil {
                print(error!)
            } else {
                for document in snapshot!.documents {
                    if let snapshotValue = document.data() as? [String : Any] {
                        
                        let userId = snapshotValue["userID"] as? String

                        if userId == self.currentUID {
                            self.currentUser.firstName = snapshotValue["firstname"] as? String
                            self.currentUser.lastName = snapshotValue["lastname"] as? String
                            self.currentUser.email = snapshotValue["email"] as? String
                            self.currentUser.uid = snapshotValue["userID"] as? String
                            self.currentUser.aboutUser = snapshotValue["aboutUser"] as? String
                            self.currentUser.aboutDog = snapshotValue["aboutUserDog"] as? String
                            self.currentUser.photoURL = snapshotValue["photoURL"] as? String                                                    
                            
                            
                        } else {
                            
                            self.user.firstName = snapshotValue["firstname"] as? String
                            self.user.lastName = snapshotValue["lastname"] as? String
                            self.user.email = snapshotValue["email"] as? String
                            self.user.uid = snapshotValue["userID"] as? String
                            self.user.aboutUser = snapshotValue["aboutUser"] as? String
                            self.user.aboutDog = snapshotValue["aboutUserDog"] as? String
                            self.user.photoURL = snapshotValue["photoURL"] as? String
                            
                            self.allUsersArray.append(self.user)
                        }
                    }
                }
                self.checkIfUserIsFriends()
            }
            self.filterUsersToShow()
        }
    }
    
    func loadViewWithInformation() {
        // Visar info om användare på index 0
        if allUsersArray.isEmpty == true {
            infoLabel.text = "Inga mer användare inom räckhåll"
            //TODO: - Sätta en default bild när inga användare finns kvar i arrayen
        } else {
            let url = URL(string: allUsersArray[0].photoURL ?? "No pic")
            infoLabel.text = allUsersArray[0].aboutUser
            imageView.kf.setImage(with: url)
            print(allUsersArray)
        }
    }
    
    func filterArrayForUser() {
        for match in allUsersArray {
            for str in currentUserArray {
                if match.uid == str {
                    allUsersArray = allUsersArray.filter { !currentUserArray.contains($0.uid!) }
                }
            }
        }
        loadViewWithInformation()
    }
    
    
    //MARK: - Buttons Methods
    @IBAction func yesButtonPressed(_ sender: UIButton) {
        
        if allUsersArray.isEmpty == true {
            
        } else {
            friendRequestSent()
            friendRequestReceived()
            checkIfUserIsFriends()
            
            allUsersArray.remove(at: 0)
            loadViewWithInformation()
        }
    }
    
    @IBAction func noButtonPressed(_ sender: UIButton) {
        
        if allUsersArray.isEmpty == true {
            
        } else {
            
            let userRef = db.collection("users").document(currentUID!)
            
            userRef.updateData([
                "noFriends": FieldValue.arrayUnion([allUsersArray[0].uid as Any])
            ]) { err in
                if let err = err {
                    print("Error updating document: \(err)")
                } else {
                    print("User nofriends successfully added")
                }
            }
            allUsersArray.remove(at: 0)
            loadViewWithInformation()
        }
    }

    //MARK: - Query DB Methods
    func filterUsersToShow() {
        db.collection("users").document(currentUID!).getDocument { (snapshot, error) in
            if let document = snapshot {
                let friendsArray = document["friends"] as? Array ?? [""]
                let noFriendsArray = document["noFriends"] as? Array ?? [""]
                
                for i in friendsArray {
                    self.currentUserArray.append(i)
                }
                for i in noFriendsArray {
                    self.currentUserArray.append(i)
                }
                
                self.filterArrayForUser()
            }
        }
    }
    
    func friendRequestSent() {
        let userRef = db.collection("users").document(currentUID!)
        
        
         // Set friendRequestSent to id of userID
        userRef.updateData([
            "friendRequestSent": FieldValue.arrayUnion([allUsersArray[0].uid as Any])
        ]) { err in
            if let err = err {
                print("Error updating document: \(err)")
            } else {
                print("friendRequest successfully sent")
            }
        }
    }
    
    func friendRequestReceived() {
        
        if let userUID = allUsersArray[0].uid {
            let userRef = db.collection("users").document(userUID)
            
            userRef.updateData([
                "friendRequestReceived": FieldValue.arrayUnion([currentUID as Any])
            ]) { (err) in
                if let err = err {
                    print("Error updating document: \(err)")
                } else {
                    print("friendRequest successfully received")
                }
            }
        }
    }
    
    func checkIfUserIsFriends () {
        
        db.collection("users").document(currentUID!).getDocument { (snapshot, error) in
            if error != nil {
                print("Something went wrong checking if user is friends \(error!)")
            } else {
                if let document = snapshot {
                    let sentArray = document["friendRequestSent"] as? Array ?? [""]
                    let receivedArray = document["friendRequestReceived"] as? Array ?? [""]
                    
                    // Loopar igenom båda arrays och kollar ifall index i är samma som n. Lägger till som vän
                    for i in receivedArray {
                        for n in sentArray {
                            if i == n && i != "" {
                                let sameIdConfirmed = i
                                
                                let userRef = self.db.collection("users").document(self.currentUID!)
                                
                                // Uppdaterar friends array i DB finns ingen skapas den.
                                // Tar även bort id från sent och received arrays.
                                userRef.updateData([
                                    "friends": FieldValue.arrayUnion([sameIdConfirmed]),
                                    "friendRequestSent": FieldValue.arrayRemove([sameIdConfirmed]),
                                    "friendRequestReceived": FieldValue.arrayRemove([sameIdConfirmed])
                                ]) { err in
                                    if let err = err {
                                        print("Error \(err)")
                                    } else {
                                        print("Updated documents success, added friend and removed id")
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        
        if let userTVC = segue.destination as? UsersTableViewController{
            userTVC.currentUser = currentUser
        }
        
        if let profileVC = segue.destination as? ProfileViewController {
            profileVC.delegate = self
            profileVC.currentUser = currentUser
            
        }
    }
    
    //MARK: - Delegate method
    func passBack(_ currentUser: Users) {
        print("Här är passback metoden")
        self.currentUser = currentUser
        print(currentUser)
        loadViewWithInformation()
    }
    

}
