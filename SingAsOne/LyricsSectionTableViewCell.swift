//
//  LyricsSectionTableViewCell.swift
//  SingAsOne
//
//  Created by LaParure on 3/5/15.
//  Copyright (c) 2015 Jia Wen Li. All rights reserved.
//

import UIKit

class LyricsSectionTableViewCell: UITableViewCell,UIPickerViewDataSource,UIPickerViewDelegate {
    let pickerData = [
        ["English","French","Russian","Chinese"]
    ]

    override func awakeFromNib() {
        super.awakeFromNib()
        langPicker.delegate = self
        langPicker.dataSource = self
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    var langs:[[String]]?{
        didSet{
            stanzaLabel?.text = "Stanza " + String(index! + 1)
            langText = pickerData[0][0]
           updateLyrics()
        }
    }
    var index:Int?{
        didSet{
            
        }
    }
    var langIndex = 0
    var langText  = ""
    var lyricsShown = ""
    func updateLyrics(){
        var lyr = langs![langIndex]
        lyrics!.text = lyr[index!]
        lyricsShown = lyr[index!]
        record.tag = index!
    }
    @IBOutlet weak var stanzaLabel: UILabel!
    @IBOutlet weak var record: UIButton!
    @IBOutlet weak var langPicker: UIPickerView!
    @IBOutlet weak var lyrics: UILabel!
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return pickerData.count
    }
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData[component].count
    }
    func pickerView(pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusingView view: UIView!) -> UIView
    {
        var pickerLabel = UILabel()
        pickerLabel.textColor = UIColor.blackColor()
        pickerLabel.text = pickerData[component][row]
        pickerLabel.font = UIFont(name: "Arial-BoldMT", size: 12) // In this use your custom font
        pickerLabel.textAlignment = NSTextAlignment.Center
        return pickerLabel
    }
    func createHomeButtonView() -> UILabel {
        

        var label = UILabel(frame: CGRectMake(0.0, 0.0, 100.0, 40.0))
        
        label.text = "Languages";
        label.textColor = UIColor.whiteColor()
        label.textAlignment = NSTextAlignment.Center
        label.layer.cornerRadius = label.frame.size.height / 2.0;
        label.backgroundColor = UIColor(red:0.0,green:0.0,blue:0.0,alpha:0.5)
        label.clipsToBounds = true;
        
        return label;
    }
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        updateLabel()
    }
    func updateLabel(){
        langIndex = langPicker.selectedRowInComponent(0)
        updateLyrics()
        langText = pickerData[0][langIndex]
        println("The lang is " + langText)

    }
}
