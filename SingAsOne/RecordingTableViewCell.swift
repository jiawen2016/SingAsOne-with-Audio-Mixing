//
//  RecordingTableViewCell.swift
//  SingAsOne
//
//  Created by LaParure on 3/10/15.
//  Copyright (c) 2015 Jia Wen Li. All rights reserved.
//

import UIKit
import AVFoundation
class RecordingTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var userLabel: UILabel!
    var index : Int?
    var audioLang : String?
    var audioUser : String?{
        didSet{
            userLabel.text = "uploaded by " + audioUser! + " in " + audioLang!
        }
    }
    var audioData: NSData?{
        didSet{
            var error: NSError?
            audioPlayer = AVAudioPlayer(data: audioData, error: &error)
        }
    }
    @IBAction func playRecording(sender: AnyObject) {
        var error: NSError?
        if let err = error {
            println("audioPlayer error: \(err.localizedDescription)")
        } else {
            audioPlayer?.play()
        }

    }
    @IBAction func stopPlaying(sender: AnyObject) {
        audioPlayer?.stop()
        var error: NSError?
        audioPlayer = AVAudioPlayer(data: audioData, error: &error)

    }
    var audioPlayer:AVAudioPlayer?
    /*
    func playRecordings(){
        for audioData in dataArr!{
            var error: NSError?
            audioPlayer = AVAudioPlayer(data: audioData, error: &error)
            
            if let err = error {
                println("audioPlayer error: \(err.localizedDescription)")
            } else {
                audioPlayer?.play()
                while(audioPlayer?.playing == true ){
                    
                }
            }
        }
    }
    */

}
