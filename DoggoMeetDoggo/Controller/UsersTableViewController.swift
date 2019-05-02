//
//  UsersTableViewController.swift
//  DoggoMeetDoggo
//
//  Created by Jonatan Bengtsson on 2019-04-10.
//  Copyright © 2019 Jonatan Bengtsson. All rights reserved.
//

import UIKit
import Firebase
import Kingfisher

class UsersTableViewController: UITableViewController {
    
    let db = Firestore.firestore()
    let currentUID = Auth.auth().currentUser?.uid
    var friendsArray = [String]()
    var loadFriendsArray = [Users]()
    
    var currentUser = Users()
    var userToChat = Users()
    
    var selectedCell: Int!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadFriendsForUser()
        
        print(friendsArray)
 
        navigationItem.title = "Meddelanden"
        
        tableView.rowHeight = 80.0
    }
    
    @objc func viewTapped(_ sender: UITapGestureRecognizer) {
        
        selectedCell = sender.view!.tag
        performSegue(withIdentifier: "goToProfileForUser", sender: self)
    }
    
    
    //MARK: - Query DB for tableView
    func loadFriendsForUser() {
        db.collection("users").document(currentUID!).getDocument { (snapshot, error) in
            if let document = snapshot {
                self.friendsArray = document["friends"] as? Array ?? [""]
                
                self.filterArrayToUsers()
            }
        }
    }
    
    func filterArrayToUsers() {
        
        if friendsArray.isEmpty || friendsArray.first == "" {
            friendsArray.removeAll()
        } else {
            
            for idOfUser in friendsArray {
                
                db.collection("users").document(idOfUser).getDocument { (snapshot, error) in
                    if let document = snapshot {
                        
                        var user = Users()
                        user.firstName = document["firstname"] as? String
                        user.lastName = document["lastname"] as? String
                        user.email = document["email"] as? String
                        user.uid = document["userID"] as? String
                        user.aboutUser = document["aboutUser"] as? String
                        user.aboutDog = document["aboutUserDog"] as? String
                        user.photoURL = document["photoURL"] as? String
                        
                        self.loadFriendsArray.append(user)
                        self.tableView.reloadData()
                    }
                }
            }
        }
    }
    

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        
        if loadFriendsArray.isEmpty {
            return 1
        }
        
        return loadFriendsArray.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! UsersTableViewCell
 
        if loadFriendsArray.isEmpty == true {
            cell.nameLabel.text = "Inga vänner än"
        } else {
            
            //TODO: - Make a tap recognizer on imageView and make performSegue
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(viewTapped(_:)))
            cell.profilImageView.isUserInteractionEnabled = true
            
            let url = URL(string: loadFriendsArray[indexPath.row].photoURL ?? "No pic")
            cell.nameLabel.text = "\(loadFriendsArray[indexPath.row].firstName ?? "Förnamn") \(loadFriendsArray[indexPath.row].lastName ?? "Efternamn")"
            cell.profilImageView.kf.setImage(with: url)
            cell.profilImageView.tag = indexPath.row
            
            cell.profilImageView.addGestureRecognizer(tapGesture)
            
            return cell
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if loadFriendsArray.isEmpty {
            
        } else {
            userToChat = loadFriendsArray[indexPath.row]
            performSegue(withIdentifier: "goToChat", sender: self)
        }
    }
    
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
        
        let chatVC = segue.destination as? ChatViewController
        chatVC?.otherUser = userToChat
        chatVC?.currentUser = currentUser
        
//        let otherPVC = segue.destination as? OtherUserProfileViewController
//        otherPVC?.user = userToChat
        
        
        if segue.identifier == "goToProfileForUser" {
            let otherPVC: OtherUserProfileViewController = segue.destination as! OtherUserProfileViewController
           otherPVC.user = loadFriendsArray[selectedCell]
        }
        
     }
    

}
