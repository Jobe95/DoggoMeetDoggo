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

class ProfileViewController: UIViewController, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
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
    
    var selectedImage: UIImage?
    let storage = Storage.storage()

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
        
        let tapGestureOnImage = UITapGestureRecognizer(target: self, action: #selector(imageViewTapped))
        profileImageView.addGestureRecognizer(tapGestureOnImage)
        
        profileImageView.isUserInteractionEnabled = true
        
        profileImageView.layer.cornerRadius = 8.0
        profileImageView.clipsToBounds = true
        
        aboutUserTextView.delegate = self
        aboutDogTextView.delegate = self

        // Do any additional setup after loading the view.
    }
    
    //MARK: - Storage Methods
    func uploadImageToDB() {
        
        var profileImageURL: String?
        
        let imageName = NSUUID().uuidString
        let storageRef = self.storage.reference().child("profile_images").child("\(imageName).png")
        
        guard let imageData = selectedImage?.pngData() else {
            print("No picture")
            return
        }
        storageRef.putData(imageData, metadata: nil) { metadata, error in
            if error != nil {
                print("Something went wrong")
                print(error!)
            } else {
                storageRef.downloadURL(completion: { (url, error) in
                    
                    profileImageURL = url?.absoluteString
                    print("Printar urlllll")
                    print(profileImageURL!)
                    
                    let userRef = self.db.collection("users").document(self.currentUID!)
                    userRef.updateData([
                        "photoURL":profileImageURL ?? "No URL",
                        "imageRef": imageName
                        ], completion: { (error) in
                        if error != nil {
                            print("Something went wrong")
                        } else {
                            print("Image Updated successfully to DB")
                            self.currentUser?.photoURL = profileImageURL
                            self.currentUser?.imageRef = imageName
                            self.loadLabels()
                        }
                    })
                })
            }
        }
    }
    
    func deleteImageFromDB() {
        // Create a reference to the file to delete
        let desertRef = storage.reference().child("profile_images").child("\(currentUser?.imageRef ?? "no image").png")
        
        // Delete the file
        desertRef.delete { error in
            if error != nil {
                // Uh-oh, an error occurred!
            } else {
                // File deleted successfully
                print("Deleted image")
            }
        }
    }

    // Declare tableViewTapped here:
    @objc func viewTapped() {
        print("View tapped")
        aboutUserTextView.endEditing(true)
        aboutDogTextView.endEditing(true)
        loadLabels()
    }
    @objc func imageViewTapped() {
        print("ImageView Tapped")
        let imagePicker = UIImagePickerController()
        
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        
        present(imagePicker, animated: true, completion: nil)
    }
    
    func loadLabels() {
        print("Printar user")
        print(currentUser!)
        
        let url = URL(string: currentUser?.photoURL ?? "No pic")
        
        userNameLabel.text = "\(currentUser?.firstName ?? "Förnamn") \(currentUser?.lastName ?? "Efternamn")"
        aboutUserLabel.text = "Om dig själv"
        aboutUserTextView.text = "\(currentUser?.aboutUser ?? "Info om dig själv")"
        aboutDogTextView.text = "\(currentUser?.aboutDog ?? "Info om din/dina hundar")"
        profileImageView.kf.setImage(with: url)
        delegate?.passBack(currentUser!)
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
    
    //MARK: - ImagePicker Methods
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("Did cancel")
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        
        if let editedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            selectedImage = editedImage
        }
        else if let originalImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            selectedImage = originalImage
        }
        guard selectedImage != nil else {
            print("No selected image")
            return
        }
        dismiss(animated: true, completion: nil)
        deleteImageFromDB()
        uploadImageToDB()
        
    }
    
    
    
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
