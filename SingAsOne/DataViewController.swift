//
//  DataViewController.swift
//  SingAsOne
//
//  Created by LaParure on 3/5/15.
//  Copyright (c) 2015 Jia Wen Li. All rights reserved.
//

import UIKit
import AVFoundation


class DataViewController: UIViewController {
    var dataArr: [NSData]?
    override func viewDidLoad() {
        super.viewDidLoad()
        dataArr = Array()
        if applicationFileExistAtPath(false, fileName: "sound.caf", directory: ""){
            
            var data = applicationReadDataToFileAtPath(dataTypeArray: true,fileName: "sound.caf", directory: "") as NSData
            let file = PFFile(name:"sound.caf", data:data)
            file.saveInBackground()
            var recorded = PFObject(className:"UserRecordings")
            recorded["user"] = "Joe Smith"
            recorded["recording"] = file
            let saveStatus = recorded.save()
            loadData()
            //println("\n获取file数据 : \(data)")
            
        }else{
            println("no such file")
        }

        // Do any additional setup after loading the view.
    }
    
    func loadData() {
        
        var query = PFQuery(className: "UserRecordings")
        query.orderByDescending("objectId")
        
        
        query.findObjectsInBackgroundWithBlock ({(objects:[AnyObject]!, error: NSError!) in
            if(error == nil){
                self.getAudioData(objects as [PFObject])                //self.getAudioData(objects as [PFObject])
            
                

                // TODO: Hide HUD - Done
                // Continue
                // Set the table view data source / delegation
                // Show objects - reloadData
                
            }
            else{
                
                println("Error in retrieving \(error)")
                // TODO: Error 0.5 - Hide HUD
            }
            
        })//findObjectsInBackgroundWithblock - end

        // TODO: Show HUD - Loading...
        
    }
    
    func getAudioData(objects:[PFObject]) {
        for object in objects {
            
            let audio = object["recording"] as PFFile
            
            audio.getDataInBackgroundWithBlock({
                (audioData: NSData!, error: NSError!) -> Void in
                if (error == nil) {
                    self.dataArr?.append(audioData)
                    println(audio.name)
                    //self.playRecordings()
                }
                
            })//getDataInBackgroundWithBlock - end
            
        }//for - end
    }
    var audioPlayer:AVAudioPlayer?
    func playRecordings(){
         println("why not play")
        for audioData in dataArr!{
            var error: NSError?
            audioPlayer = AVAudioPlayer(data: audioData, error: &error)
            
            if let err = error {
                println("audioPlayer error: \(err.localizedDescription)")
            } else {
                println("why not play")
                audioPlayer?.play()
            while((audioPlayer?.play()) != nil){
                
            }
            }
        }

    }
    func retrieveData(){
        var query = PFQuery(className:"UserRecordings")
        query.findObjectsInBackgroundWithBlock { (objects: [AnyObject]!, error: NSError!) -> Void in
            if error == nil {
                for object in objects {
                    // Do something
                    let uploaded = object["recording"] as PFFile
                    /*
                    uploaded.getDataInBackgroundWithBlock({
                        (audioData: NSData!, error: NSError!) -> Void in
                        if (error == nil) {
                            var error: NSError?
                            var audioPlayer = AVAudioPlayer(data: audioData, error: &error)
                            //audioPlayer?.delegate = self
                            
                            if let err = error {
                                println("audioPlayer error: \(err.localizedDescription)")
                            } else {
                                audioPlayer?.play()
                                while((audioPlayer?.play()) != nil){
                                    
                                }
                            }
                            
                        }
                        
                    })//getDataInBackgroundWithBlock - end
    */
                    
                    let uploadedData = uploaded.getData()
                    var error: NSError?
                    var audioPlayer = AVAudioPlayer(data: uploadedData, error: &error)
                    //audioPlayer?.delegate = self
                    
                    if let err = error {
                        println("audioPlayer error: \(err.localizedDescription)")
                    } else {
                        audioPlayer?.play()
                        while((audioPlayer?.play()) != nil){
                            
                        }
                    }


                }
            } else {
                println(error)
            }
        }
        

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func applicationFileExistAtPath(fileTypeDirectory: Bool ,fileName: String ,directory: String) ->Bool {
        
        var filePath = applicationFilePath(fileName, directory: directory)
        
        if fileTypeDirectory {//普通文件（图片、plist、txt等等）
            
            return NSFileManager.defaultManager().fileExistsAtPath(filePath)
            
        }else{//文件夹
            
            //UnsafeMutablePointer<ObjCBool> 不能再直接使用  Bool  类型
            
            var isDir : ObjCBool = false
            
            return NSFileManager.defaultManager().fileExistsAtPath(filePath, isDirectory: &isDir)
            
        }
    }
        func applicationFilePath(fileName: String ,directory: String) ->String {
            
            var docuPath = applicationDocumentPath()
            
            if directory.isEmpty {
                
                return docuPath.stringByAppendingPathComponent(fileName)
                
            }else{
                
                return docuPath.stringByAppendingPathComponent("\(directory)/\(fileName)")
                
            }
            
        }
    func applicationDocumentPath() ->String{
        
        let application = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        
        let documentPathString = application[0] as String
        
        return documentPathString
        
    }
        
    func applicationReadDataToFileAtPath(#dataTypeArray: Bool ,fileName: String ,directory: String) -> AnyObject{
        
        var filePath = applicationFilePath(fileName, directory: directory)
        
        if dataTypeArray {
            
        return NSData(contentsOfFile: filePath)!
            
        }else{
            
            return NSDictionary(contentsOfFile: filePath)!
            
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
