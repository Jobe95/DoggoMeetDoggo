//
//  OtherUserProfileViewController.swift
//  DoggoMeetDoggo
//
//  Created by Jonatan Bengtsson on 2019-04-30.
//  Copyright © 2019 Jonatan Bengtsson. All rights reserved.
//

import UIKit
import Kingfisher
import Firebase
import ChameleonFramework

class OtherUserProfileViewController: UIViewController {
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var userImageView: UIImageView!
    
    @IBOutlet weak var topTextField: UITextView!
    @IBOutlet weak var bottomTextField: UITextView!
    
    @IBOutlet weak var backView: UIView!
    var user: Users?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let url = URL(string: (user?.photoURL)!)
        
        userImageView.kf.setImage(with: url)
        
        userImageView.layer.cornerRadius = userImageView.frame.size.width / 2
        userImageView.clipsToBounds = true
        
        

        
        backView.backgroundColor = UIColor .lightGray
        
        topTextField.text = user?.aboutUser
        bottomTextField.text = user?.aboutDog
        
        topTextField.isEditable = false
        bottomTextField.isEditable = false
        
        

        // Do any additional setup after loading the view.
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
