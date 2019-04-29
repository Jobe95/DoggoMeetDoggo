//
//  ChatTableViewCell.swift
//  DoggoMeetDoggo
//
//  Created by Jonatan Bengtsson on 2019-04-17.
//  Copyright © 2019 Jonatan Bengtsson. All rights reserved.
//

import UIKit

class ChatTableViewCell: UITableViewCell {
   
    
    @IBOutlet weak var profilImageView: UIImageView!
    
    @IBOutlet weak var messageView: UIView!
    
    @IBOutlet weak var senderLabel: UILabel!
    @IBOutlet weak var messageTextLabel: UILabel!
    
    
    @IBOutlet weak var currentUserMessageView: UIView!
    @IBOutlet weak var currentUserSenderLabel: UILabel!
    @IBOutlet weak var currentUserMessageTextLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
