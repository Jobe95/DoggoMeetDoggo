//
//  ChatViewController.swift
//  DoggoMeetDoggo
//
//  Created by Jonatan Bengtsson on 2019-04-17.
//  Copyright © 2019 Jonatan Bengtsson. All rights reserved.
//

import UIKit
import Firebase

class ChatViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {

    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    @IBOutlet weak var messageTableView: UITableView!
    @IBOutlet weak var messageTextField: UITextField!
    @IBOutlet weak var sendButtonOutlet: UIButton!
    
    let db = Firestore.firestore()
    
    var currentUser = Users()
    var otherUser = Users()
    
    var messageArray = [Message]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        messageTableView.delegate = self
        messageTableView.dataSource = self
        
        messageTextField.delegate = self
        
        //TODO: Set the tapGesture here:
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tableViewTapped))
        messageTableView.addGestureRecognizer(tapGesture)
        
        
        configureTableView()
        retrieveMessage()
        
        messageTableView.separatorStyle = .none
        
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messageArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MessageCell", for: indexPath) as! ChatTableViewCell
        
        cell.usernameLabel.text = messageArray[indexPath.row].sender
        cell.messageLabel.text = messageArray[indexPath.row].messageText
        
        if cell.usernameLabel.text == currentUser.firstName {
            cell.profilImageView.backgroundColor = #colorLiteral(red: 0, green: 0.9810667634, blue: 0.5736914277, alpha: 1)
            cell.messageContainerView.backgroundColor = #colorLiteral(red: 0.01680417731, green: 0.1983509958, blue: 1, alpha: 1)
        } else {
            cell.profilImageView.backgroundColor = #colorLiteral(red: 0, green: 0.5690457821, blue: 0.5746168494, alpha: 1)
            cell.messageContainerView.backgroundColor = #colorLiteral(red: 0.6642242074, green: 0.6642400622, blue: 0.6642315388, alpha: 1)
        }
        
        return cell
    }
    
    
    //TODO: Declare tableViewTapped here:
    @objc func tableViewTapped() {
        messageTextField.endEditing(true)
    }
    
    //TODO: Declare configureTableView here:
    func configureTableView() {
//        messageTableView.rowHeight = UITableView.automaticDimension
//        messageTableView.estimatedRowHeight = 120.0
        messageTableView.rowHeight = 80.0
    }
    
    
    //MARK: - TextField Delegate Methods
    
    //TODO: Declare textFieldDidBeginEditing here:
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        UIView.animate(withDuration: 0.2){
            self.heightConstraint.constant = 267
            self.view.layoutIfNeeded()
        }
    }
    
    //TODO: Declare textFieldDidEndEditing here:
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        UIView.animate(withDuration: 0.2) {
            self.heightConstraint.constant = 50
            self.view.layoutIfNeeded()
        }
    }
    
    func setOneToOneChat(uid1: String, uid2: String) -> String {
        //Check if user1’s id is less than user2's
        if uid1 < uid2 {
            return uid1+uid2;
        }
        else{
            return uid2+uid1;
        }
    }
    
    @IBAction func sendButtonpressed(_ sender: UIButton) {
        
        messageTextField.endEditing(true)
        //TODO: Send the message to Firebase and save it in our database
        messageTextField.isEnabled = false
        sendButtonOutlet.isEnabled = false
        
        let chatRoomId = setOneToOneChat(uid1: currentUser.uid!, uid2: otherUser.uid!)
        print(chatRoomId)
        
        
        let messageDictionary = ["messageBody": messageTextField.text!,
                                 "sender": currentUser.firstName!,
                                 "messageCreated": Date()] as [String : Any]
        
        let chatRef = db.collection("chatRooms").document(chatRoomId).collection("Messages")
            
        chatRef.addDocument(data: messageDictionary ) {
            (error) in
            if error != nil {
                print("Something went wrong")
            } else {
                print("Success saved message to DB")
                self.messageTextField.isEnabled = true
                self.sendButtonOutlet.isEnabled = true
                self.messageTextField.text = ""
            }
        }
    }
    
    //TODO: Create retrieve message method here
    
    func retrieveMessage() {
        let chatRoomId = setOneToOneChat(uid1: currentUser.uid!, uid2: otherUser.uid!)
        
        let messageDB = db.collection("chatRooms").document(chatRoomId).collection("Messages").order(by: "messageCreated", descending: false)
        
        messageDB.addSnapshotListener { (snapshot, error) in
            
            snapshot?.documentChanges.forEach { diff in
                if (diff.type == .added) {
                    print("New city: \(diff.document.data())")
                    
                    var snapshotValue = diff.document.data() as? [String : Any]
                    let text = snapshotValue!["messageBody"]
                    let sender = snapshotValue!["sender"]
                    var message = Message()
                    
                    message.messageText = text as! String
                    message.sender = sender as! String
                    self.messageArray.append(message)
                    self.configureTableView()
                    self.messageTableView.reloadData()
                }
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
