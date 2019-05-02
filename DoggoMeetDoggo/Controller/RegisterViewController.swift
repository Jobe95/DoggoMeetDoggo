//
//  RegisterViewController.swift
//  DoggoMeetDoggo
//
//  Created by Jonatan Bengtsson on 2019-04-10.
//  Copyright © 2019 Jonatan Bengtsson. All rights reserved.
//

import UIKit
import Firebase

class RegisterViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    
    let db = Firestore.firestore()
    let storage = Storage.storage()
    
    var selectedImage: UIImage?
    
    @IBOutlet weak var addPhoto: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    
    func createNewUser(url: String?, imageRef: String?) {
        
        Auth.auth().createUser(withEmail: emailTextField.text!, password: passwordTextField.text!) { user, error in
            
            if error != nil {
                // Något fel har hänt
                print("Cannot create user \(error!)")
            } else {
                // Registrera användare fungerar
                print("Create user works fine")
                
                let uid = Auth.auth().currentUser?.uid
                
                self.db.collection("users").document(uid!).setData([
                    "firstname": self.firstNameTextField.text!,
                    "lastname": self.lastNameTextField.text!,
                    "userID": uid!,
                    "email": self.emailTextField.text!,
                    "photoURL": url ?? "No url",
                    "imageRef": imageRef ?? "No imageRef"
                ]) { err in
                    if let err = err {
                        print("Error writing document: \(err)")
                    } else {
                        print("Document successfully written!")
                        self.performSegue(withIdentifier: "goToSlide", sender: self)
                    }
                }
            }
        }
    
    }
    
    func uploadImageToDB() {
        
        var profileImageURL: String?
        
        let imageName = NSUUID().uuidString
        let storageRef = self.storage.reference().child("profile_images").child("\(imageName).png")
        
        guard let imageData = selectedImage?.pngData() else {
            self.createNewUser(url: "No picture added", imageRef: imageName)
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
                    
                    self.createNewUser(url: profileImageURL!, imageRef: imageName)
                })
            }
        }
    }
    
    //MARK: - Buttons pressed
    @IBAction func addPhotoButtonPressed(_ sender: UIButton) {
        let imagePicker = UIImagePickerController()
        
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        
        present(imagePicker, animated: true, completion: nil)
        
    }
    
    
    @IBAction func registerButtonPressed(_ sender: UIButton) {
        uploadImageToDB()
        
    }
    
    //MARK: - Imagepicker methods
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
        
    }
    
    
    
    // MARK: - Navigation
    /*
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
 */

}
