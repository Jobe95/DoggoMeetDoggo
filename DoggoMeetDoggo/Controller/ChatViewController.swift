//
//  ChatViewController.swift
//  DoggoMeetDoggo
//
//  Created by Jonatan Bengtsson on 2019-04-17.
//  Copyright © 2019 Jonatan Bengtsson. All rights reserved.
//

import UIKit
import Firebase
import ChameleonFramework
import Kingfisher

class ChatViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {

    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    @IBOutlet weak var messageTableView: UITableView!
    @IBOutlet weak var messageTextField: UITextField!
    @IBOutlet weak var sendButtonOutlet: UIButton!
    
    let db = Firestore.firestore()
    
    var currentUser = Users()
    var otherUser = Users()
    
    var oURL: URL?
    
    var messageArray = [Message]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        oURL = URL(string: otherUser.photoURL ?? "No pic")
        
        
        messageTableView.delegate = self
        messageTableView.dataSource = self
        
        messageTextField.delegate = self
        
        // Set the tapGesture here:
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tableViewTapped))
        messageTableView.addGestureRecognizer(tapGesture)
        
        
        //TODO: Register your MessageCell.xib file here:
        messageTableView.register(UINib(nibName: "MessageCell", bundle: nil), forCellReuseIdentifier: "MessageCell")
        
        
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
        
        cell.senderLabel.text = messageArray[indexPath.row].sender
        cell.messageTextLabel.text = messageArray[indexPath.row].messageText
        
        if cell.senderLabel.text == currentUser.firstName {
            cell.messageView.isHidden = true
            cell.profilImageView.isHidden = true
            cell.currentUserMessageView.isHidden = false
            
            cell.currentUserMessageTextLabel.text = messageArray[indexPath.row].messageText
            cell.currentUserSenderLabel.text = messageArray[indexPath.row].sender
            cell.currentUserMessageView.backgroundColor = UIColor .flatSkyBlue
        } else {
            cell.currentUserMessageView.isHidden = true
            cell.messageView.isHidden = false
            cell.profilImageView.isHidden = false
            
            cell.profilImageView.backgroundColor = UIColor .flatWatermelon
            cell.profilImageView.kf.setImage(with: oURL)
            cell.messageView.backgroundColor = UIColor .flatGray
        }
        
        return cell
    }
    
    
    // Declare tableViewTapped here:
    @objc func tableViewTapped() {
        messageTextField.endEditing(true)
    }
    
    //TODO: - Fixa så messageTableView.rowHeight ökar om man skriver ett väldigt långt meddelande
    // Declare configureTableView here:
    func configureTableView() {
        messageTableView.rowHeight = UITableView.automaticDimension
        messageTableView.estimatedRowHeight = 120.0
    }
    
    
    //MARK: - TextField Delegate Methods
    
    // Declare textFieldDidBeginEditing here:
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        UIView.animate(withDuration: 0.2){
            self.heightConstraint.constant = 267
            self.view.layoutIfNeeded()
        }
    }
    
    // Declare textFieldDidEndEditing here:
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        UIView.animate(withDuration: 0.2) {
            self.heightConstraint.constant = 50
            self.view.layoutIfNeeded()
        }
    }
    
    func setOneToOneChat(currentUserId: String, otherUserId: String) -> String {
        //Check if user1’s id is less than user2's
        if currentUserId < otherUserId {
            return currentUserId+otherUserId;
        }
        else{
            return otherUserId+currentUserId;
        }
    }
    
    @IBAction func sendButtonpressed(_ sender: UIButton) {
        // Send the message to Firebase and save it in DB
        
        messageTextField.endEditing(true)
        messageTextField.isEnabled = false
        sendButtonOutlet.isEnabled = false
        
        let chatRoomId = setOneToOneChat(currentUserId: currentUser.uid!, otherUserId: otherUser.uid!)
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
        let chatRoomId = setOneToOneChat(currentUserId: currentUser.uid!, otherUserId: otherUser.uid!)
        
        let messageDB = db.collection("chatRooms").document(chatRoomId).collection("Messages").order(by: "messageCreated", descending: false)
        
        messageDB.addSnapshotListener { (snapshot, error) in
            
            snapshot?.documentChanges.forEach { diff in
                if (diff.type == .added) {
                    //print("New Data added: \(diff.document.data())")
                    guard let snapshotValue = diff.document.data() as? [String : Any] else {
                        print("No data in document")
                        return
                    }
                    let text = snapshotValue["messageBody"]
                    let sender = snapshotValue["sender"]
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
