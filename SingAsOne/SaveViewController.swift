//
//  saveViewController.swift
//  SingAsOne
//
//  Created by LaParure on 3/12/15.
//  Copyright (c) 2015 Jia Wen Li. All rights reserved.
//

import UIKit

class SaveViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        shareButton.hidden = true
        shareButton.enabled = false

        // Do any additional setup after loading the view.
    }
    var url : String?{
        didSet{
            
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    var synData: NSUserDefaults = NSUserDefaults.standardUserDefaults()
    var currentUserName: NSUserDefaults = NSUserDefaults.standardUserDefaults()
    var objectId:String?
    @IBOutlet weak var saveProgressBar: UIProgressView!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var inputTextField: UITextField!

    @IBAction func saveSong(sender: UIButton) {
        let recordedData = NSData(contentsOfURL:NSURL(fileURLWithPath: url!)!)
        var recordName = inputTextField.text!+".m4a"
        let file = PFFile(name:recordName, data:recordedData)
        
        file.saveInBackgroundWithBlock({ (succeeded: Bool, error: NSError!) -> Void in
            
            // Check there was no error, begin handling the file upload
            // trimmed out un-necessary code
            if(succeeded && error == nil){
                var recorded = PFObject(className:"UserSongs")
                var user = "Jia Li"
                if let n = self.currentUserName.objectForKey("userName")? as? String{
                    user = n
                    
                }
                recorded["user"] = user
                recorded["recording"] = file
                recorded["fileName"] = recordName
                recorded["shared"] = false
                println("saved")
                
                recorded.saveInBackgroundWithBlock({ (succeeded: Bool, error: NSError!) -> Void in
                    if(succeeded && error == nil){
                        println("uploaded")
                        self.objectId = recorded.objectId
                        self.saveButton.titleLabel?.text="Done"
                        self.saveButton.enabled = false
                        self.shareButton.hidden = false
                        self.shareButton.enabled = true
                        self.synData.setObject(0, forKey: "synthesize")
                        
                    }
                    else{
                        
                        println("Error in uploading \(error)")
                        // TODO: Error 0.5 - Hide HUD
                    }
                    
                    }
                    //update spinner
                    
                )
                
            }
            else{
                
                println("Error in saving \(error)")
                // TODO: Error 0.5 - Hide HUD
            }
            
            
            }, progressBlock: { (percentDone: Int32) -> Void in
                self.saveProgressBar.setProgress(Float(percentDone)/100.0, animated: true)
                //update spinner
                
        })
    
    }
    @IBAction func shareSong(sender: UIButton) {
        
        var query = PFQuery(className: "UserSongs")
        query.whereKey("objectId", equalTo:objectId!)
        query.findObjectsInBackgroundWithBlock {
            (objects: [AnyObject]!, error: NSError!) -> Void in
            if error == nil {
                // The find succeeded.
                //println("Successfully retrieved \(objects.count) songs.")
                // Do something with the found objects
                if let objects = objects as? [PFObject] {
                    for object in objects {
                        //println(object.objectId)
                        object["shared"] = true
                        object.saveInBackgroundWithBlock({ (succeeded: Bool, error: NSError!) -> Void in
                            if(succeeded && error == nil){
                                self.shareButton.titleLabel?.text = "Shared!"
                            }
                            else{
                                
                                println("Error in uploading \(error)")
                                // TODO: Error 0.5 - Hide HUD
                            }
                            
                            }
                        )
                    }
                }
                
                
            } else {
                // Log details of the failure
                println("Error: \(error) \(error.userInfo!)")
            }
        }
    }
    
    
    /*
   
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
