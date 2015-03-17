//
//  DisplayRecordingsTableViewController.swift
//  SingAsOne
//
//  Created by LaParure on 3/8/15.
//  Copyright (c) 2015 Jia Wen Li. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit

class DisplayRecordingsTableViewController: UITableViewController, AudioConcatenatorDelegate {
    var dataArr: [NSData]?{
        didSet {
            dispatch_async(dispatch_get_main_queue(), {
                self.setStanza()
                self.tableView.reloadData()
            })
        }
    }
    var synData: NSUserDefaults = NSUserDefaults.standardUserDefaults()
    var dataName :[String] = Array()
    var audioName :[String] = Array()
    var dataLang : [String] = Array()
    var dataUser : [String] = Array()
    var dataStanza : [Int] = Array()
    var stanzaSorted: [Int] = Array()
    var numRowsPerStanza: [Int] = Array()
    var rowsPerStanza:[[Int]] = Array()
    var selectedRowsIndex : [Int] = Array()
    var selectedDataNames : [String] = Array()
    var refreshController:UIRefreshControl!
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        synData.setObject(0, forKey: "synthesize")
        
        tableView.estimatedRowHeight = tableView.rowHeight
        tableView.rowHeight = UITableViewAutomaticDimension
        
        self.refreshController = UIRefreshControl()
        self.refreshController.attributedTitle = NSAttributedString(string: "Pull to refresh")
        self.refreshController.addTarget(self, action: "refresh", forControlEvents: UIControlEvents.ValueChanged)
        self.tableView.addSubview(refreshController)
    }
    
    override func viewDidAppear(animated: Bool) {
        
        if let synthesized = synData.objectForKey("synthesize")? as? Int{
            if synthesized == 1{
                var alert = UIAlertView(title: "Save your song?",
                    message: "",
                    delegate:self,
                    cancelButtonTitle: "Cancel")
                    alert.addButtonWithTitle("Yes")
                    alert.show()
            }
        }
        self.refresh()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        if dataArr == nil{
            return 0
        }
        if stanzaSorted.count == 0{
            return 0
        }
        return stanzaSorted.count + 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        if dataArr == nil{
            return 0
        }
        if(section  == stanzaSorted.count){
            return 1
        }
        return numRowsPerStanza[section]+1
    }
    
    private func refresh(sender: UIRefreshControl?) {
        
        var query = PFQuery(className: "UserRecordings")
        query.orderByDescending("objectId")
        query.findObjectsInBackgroundWithBlock ({(objects:[AnyObject]!, error: NSError!) in
            if(error == nil){
                self.getAudioData(objects as [PFObject],{(arr) -> Void in
//                    dispatch_async(dispatch_get_main_queue()) { () -> Void in
                        self.dataArr = arr as [NSData]
                        
                        
//                    }
                    sender?.endRefreshing()
                })
                //println(self.dataArr?.count)
                // TODO: Hide HUD - Done
                // Continue
                // Set the table view data source / delegation
                // Show objects - reloadData
            }
            else {
                
                println("Error in retrieving \(error)")
                // TODO: Error 0.5 - Hide HUD
                sender?.endRefreshing()
            }
            
        })//findObjectsInBackgroundWithblock - end
        
        
    }
    
    func setStanza(){
        stanzaSorted = dataStanza
        numRowsPerStanza.removeAll(keepCapacity: false)
        rowsPerStanza.removeAll(keepCapacity: false)
        sort(&stanzaSorted)
        var i = 0
        var j=1
        var tempStanza: [Int] = Array()
        while i < stanzaSorted.count{
            if(i==0 || stanzaSorted[i] != stanzaSorted[i-1]){
                if(i != 0){
                    numRowsPerStanza.append(j)
                }
                tempStanza.append(stanzaSorted[i])
                j=1
                
            }
            else{
                j++
                
            }
            i++
            
        }
        numRowsPerStanza.append(j)
        stanzaSorted = tempStanza
       
        for i in stanzaSorted{
            var tempPerRow : [Int] = Array()
            for(var j=0;j<dataStanza.count;j++){
                if (dataStanza[j] == i){
                    tempPerRow.append(j)
              
                }
            }
            rowsPerStanza.append(tempPerRow)
        }
        
    }
    
    func refresh() {
        refreshControl?.beginRefreshing()
        refresh(refreshController)
    }
    
    func getAudioData(objects:[PFObject],handler:([NSData])->()) {
        
        //let objectCountSemaphore = dispatch_semaphore_create(objects.count)
        
        var arr:[NSData] = Array()
        if dataArr != nil{
            arr = self.dataArr!
        }
        
        var c = 0
        for object in objects {
            
            let audio = object["recording"] as PFFile
            var name = audio.name
            
            if contains(audioName,name){
                c++
                //dispatch_semaphore_signal(objectCountSemaphore)
                if (c == objects.count){
                    handler(arr)
                    
                }
                continue
            }
            
            audio.getDataInBackgroundWithBlock( { (audioData: NSData!, error: NSError!) -> Void in
                
                if (error == nil) {
                    arr.append(audioData)
                    let lang = object["language"] as String
                    self.dataLang.append(lang)
                    let user = object["user"] as String
                    self.dataUser.append(user)
                    let stanza = object["stanza"] as Int
                    self.dataStanza.append(stanza)
                    self.audioName.append(name)
                    let len = audio.name.utf16Count
                    name = name.substringWithRange(Range<String.Index>(start: advance(name.endIndex, -5), end: name.endIndex))
                    self.dataName.append(name)

                    c++
                    if (c == objects.count){
                       handler(arr)
                      
                   }
                }
                
               // dispatch_semaphore_signal(objectCountSemaphore)
                
            })//getDataInBackgroundWithBlock - end
            
            
        }//for - end
        
//        // Wait for all to be processed
//        //println("waiting for callbacks")
//        //dispatch_semaphore_wait(objectCountSemaphore, DISPATCH_TIME_FOREVER)
//        println("done")
//        handler(arr)
    }
    
    var audioPlayer:AVAudioPlayer?
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

    
    
    func writeAllAudioDataFile(){
        handleFile.creatFileAtPath(true, fileName: "SingAsOne", dirName: "")
        for i in selectedRowsIndex{
            var audioData = dataArr![i]
            var audioName = self.audioName[i]
            selectedDataNames.append(audioName)
            writeAudioDatatoFile(audioData,audioName:audioName)
        
        }
    }
    var handleFile = WriteDataToFile()
    func concatAudioDataFiles(){
        let concat = AudioConcatenator(
            //fileDirectoryPath: NSBundle.mainBundle().resourcePath!,
            fileDirectoryPath: handleFile.getFilePath("", dirName: "SingAsOne"),
            delegate: self
        )
        //sort(&selectedDataNames)
        selectedDataNames.sort{
            //var first = $0.substringWithRange(Range<String.Index>(start: advance($0.endIndex, -5), end: $0.endIndex))
            //var second = $1.substringWithRange(Range<String.Index>(start: advance($1.endIndex, -5), end: $1.endIndex))
            var nameArr = $0.0.componentsSeparatedByString("-")
            var first = nameArr[nameArr.count-1]
            var nameArr1 = $1.0.componentsSeparatedByString("-")
            var second = nameArr1[nameArr1.count-1]
            return first<second
        }
        concat.mergeCAFs(selectedDataNames)

        
    }
    
    func writeAudioDatatoFile(audioData:NSData,audioName:String){
        
        handleFile.creatFileAtPath(false, fileName: audioName, dirName: "SingAsOne")
        handleFile.writeData(audioData, fileName: audioName, dirName: "SingAsOne")
        
    }
        var destinationURL:String?
    func audioConcatenationDidComplete(success: Bool, destinationPath:String) {
        println("concat completed")
        selectedDataNames.removeAll(keepCapacity: false)
        selectedRowsIndex.removeAll(keepCapacity: false)
        if (success){
            destinationURL = destinationPath
            dispatch_async(dispatch_get_main_queue(), {
                
                // DO SOMETHING ON THE MAINTHREAD
                var alert = UIAlertView(title: "Your song is completed!",
                    message: "Listen to your song?",
                    delegate:self,
                    cancelButtonTitle: "Cancel")
                alert.addButtonWithTitle("Yes")
                alert.show()

            })
        }
    }

    func alertView(_alertView: UIAlertView,clickedButtonAtIndex buttonIndex:Int){
        var name:NSString = _alertView.buttonTitleAtIndex(buttonIndex)
        var title:NSString = _alertView.title
        if(name.isEqualToString("Yes")){
            
            if(title.isEqualToString("Your song is completed!")){
                synData.setObject(1, forKey: "synthesize")
                performSegueWithIdentifier("playSong", sender: nil)
            }
            if(title.isEqualToString("Save your song?")){
                //synData.setObject(0, forKey: "synthesize")
                performSegueWithIdentifier("saveSong", sender: nil)
       
            }


        }
        else{
            if(title.isEqualToString("Save your song?")){
                synData.setObject(0, forKey: "synthesize")
                
            }
        }
        
        
    }
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "playSong"{
            if let avpVC = segue.destinationViewController as? AVPlayerViewController{
                dispatch_async(dispatch_get_main_queue()) {
                    let url = NSURL(fileURLWithPath: self.destinationURL!)
                    avpVC.player = AVPlayer(URL: url)
                }
            }
            
        }
        if segue.identifier == "saveSong"{
            if let saveVC = segue.destinationViewController as? SaveViewController{
                dispatch_async(dispatch_get_main_queue()) {
                    saveVC.url = self.destinationURL
                }
            }
            
        }

    }

   
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if(indexPath.section == stanzaSorted.count){
            let cell = tableView.dequeueReusableCellWithIdentifier("synthesize", forIndexPath: indexPath) as SynTableViewCell
            //var synthesized = synData.setObject(self.recordings, forKey: "recordings")
            if let synthesized = synData.objectForKey("synthesize")? as? Int{
                if(synthesized == 1 ){
                    cell.updateUI()
                    
                }
                else{
                    cell.hideUI()
                }
                
            }
            else{
                cell.hideUI()
            }
            return cell
        }
        var index = stanzaSorted[indexPath.section]

        if(indexPath.row==0){
            let cell = tableView.dequeueReusableCellWithIdentifier("titleStanza", forIndexPath: indexPath) as UITableViewCell
            cell.textLabel?.text = "Stanza "+String(index+1)
            return cell

        }
        let cell = tableView.dequeueReusableCellWithIdentifier("displayRecording", forIndexPath: indexPath) as RecordingTableViewCell
        cell.index = rowsPerStanza[indexPath.section][indexPath.row-1]
        cell.audioLang = dataLang[rowsPerStanza[indexPath.section][indexPath.row-1]]
        cell.audioUser = dataUser[rowsPerStanza[indexPath.section][indexPath.row-1]]
        cell.audioData = dataArr?[rowsPerStanza[indexPath.section][indexPath.row-1]]
        
        //cell.accessoryType = .Checkmark
        // Configure the cell...
        
        return cell
    }
    
    var selectedIndexPaths : [ NSIndexPath] = Array()
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if  indexPath.row == 0{
            return
        }
        if let  selectedCell = tableView.cellForRowAtIndexPath(indexPath) as? RecordingTableViewCell{
            if (selectedCell.accessoryType == UITableViewCellAccessoryType.None){
            
                selectedCell.accessoryType = .Checkmark
                //selectedRowsIndex.append(selectedCell.index!)
                selectedRowsIndex.append(rowsPerStanza[indexPath.section][indexPath.row-1])
                selectedIndexPaths.append(indexPath)
                
          
            }else if (selectedCell.accessoryType == UITableViewCellAccessoryType.Checkmark){
            
                selectedCell.accessoryType = .None
                for(var i = 0 ; i < selectedRowsIndex.count;i++){
                    if (selectedRowsIndex[i] == selectedCell.index!){
                        selectedRowsIndex.removeAtIndex(i)
                        break
                    }
                }
            
            }
            tableView.deselectRowAtIndexPath(indexPath, animated:false)
        }
        
    }
    
    
    @IBAction func synthesize(sender: AnyObject) {
        for i in selectedIndexPaths{
           if let  selectedCell = tableView.cellForRowAtIndexPath(i) as? RecordingTableViewCell{
                 selectedCell.accessoryType = .None
            }
        }
        selectedIndexPaths.removeAll()
        //performSegueWithIdentifier("saveSong", sender: nil)
        //var indexPath = NSIndexPath(forRow: 0,
            //inSection: stanzaSorted.count)
        //let cell = tableView.cellForRowAtIndexPath(indexPath) as SynTableViewCell
        //cell.updateUI()
        self.writeAllAudioDataFile()
        concatAudioDataFiles()
    }
  
    @IBAction func listenSong(sender: UIButton) {
        performSegueWithIdentifier("playSong", sender: nil)
    }
    @IBAction func saveSong(sender: UIButton) {
         performSegueWithIdentifier("saveSong", sender: nil)
    }
    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }

    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */
    
}
