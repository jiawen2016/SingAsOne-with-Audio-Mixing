//
//  SongTableViewController.swift
//  SingAsOne
//
//  Created by LaParure on 3/5/15.
//  Copyright (c) 2015 Jia Wen Li. All rights reserved.
//

import UIKit

class SongTableViewController: UITableViewController {
    var lyrics:[String]?{
        didSet{
           langs?.append(lyrics!)
        }
    }
    var langs:[[String]]?{
        didSet{
            
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        langs = Array()
        for(var i=0;i<4;i++){
            var name = "LetItGo" + String(i)
            let path = NSBundle.mainBundle().pathForResource(name, ofType: "txt")
            var possibleContent = String(contentsOfFile:path!, encoding: NSUTF8StringEncoding, error: nil)
            
            if let content = possibleContent {
                lyrics = content.componentsSeparatedByString("\n\n")
                for line in lyrics!{
                    println(line)
                }
            }
        }

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return lyrics!.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("line", forIndexPath: indexPath) as LyricsSectionTableViewCell
        cell.index = indexPath.row
        cell.langs = langs
        //cell.lyrics?.text = lyrics![indexPath.row]
        // Configure the cell...

        return cell
    }
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "recordSection"{
            if let recordViewController = segue.destinationViewController as? RecordViewController{
                let bu = sender as UIButton
                let buttonPosition = bu.convertPoint(CGPointZero, toView: self.tableView)
                if let indexPath = self.tableView.indexPathForRowAtPoint(buttonPosition){
                //if let indexPath = tableView.indexPathForSelectedRow()?{

                    if let source = tableView.cellForRowAtIndexPath(indexPath) as? LyricsSectionTableViewCell{
                
                        recordViewController.lyrics = source.lyricsShown
                        recordViewController.recordLang = source.langText
                    
                        println(source.lyricsShown)
                        println(source.langText)
                        recordViewController.index=bu.tag
                    }
                }
            }
            
        }
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