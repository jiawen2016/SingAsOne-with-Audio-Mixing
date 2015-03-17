//
//  SharedSongTableViewCell.swift
//  SingAsOne
//
//  Created by LaParure on 3/13/15.
//  Copyright (c) 2015 Jia Wen Li. All rights reserved.
//

import UIKit

class SharedSongTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var songName: UILabel!
}
