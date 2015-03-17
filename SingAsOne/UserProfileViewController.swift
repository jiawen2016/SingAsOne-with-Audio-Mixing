//
//  UserProfileViewController.swift
//  SingAsOne
//
//  Created by LaParure on 3/13/15.
//  Copyright (c) 2015 Jia Wen Li. All rights reserved.
//

import UIKit

class UserProfileViewController: UIViewController,UITextFieldDelegate{
    var currentUserName: NSUserDefaults = NSUserDefaults.standardUserDefaults()
    override func viewDidLoad() {
        super.viewDidLoad()
        userName = "Jia Li"
        currentUserName.setObject(userName!, forKey: "userName")
        self.inputTextField.delegate = self
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(animated: Bool) {
        nameLabel.text = "Name: " + userName!
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
   
    @IBAction func saveName(sender: UIButton) {
        if (inputTextField.text! != ""){
            userName = inputTextField.text
            currentUserName.setObject(userName!, forKey: "userName")
            nameLabel.text = "Name: " + userName!
        }
    }
    func textFieldShouldReturn(textField: UITextField!) -> Bool {
        self.view.endEditing(true)
        return false
    }
    var userName : String?
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var nameLabel: UILabel!

    @IBOutlet weak var inputTextField: UITextField!
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
