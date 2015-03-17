//
//  SynTableViewCell.swift
//  SingAsOne
//
//  Created by LaParure on 3/11/15.
//  Copyright (c) 2015 Jia Wen Li. All rights reserved.
//

import UIKit

class SynTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    func updateUI(){
        shareButton.hidden = false
        shareButton.enabled = true
        saveButton.hidden = false
        saveButton.enabled = true
        listenButton.hidden = false
        listenButton.enabled = true
    }
    func hideUI(){
       saveButton.hidden = true
        saveButton.enabled = false
        shareButton.hidden = true
        shareButton.enabled = false
        listenButton.hidden = true
        listenButton.enabled = false
    }

    @IBOutlet weak var listenButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
}
