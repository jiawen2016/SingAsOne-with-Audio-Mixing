//
//  ViewController.swift
//  SingAsOne
//
//  Created by LaParure on 3/4/15.
//  Copyright (c) 2015 Jia Wen Li. All rights reserved.
//

import Foundation
import AVFoundation

extension NSFileManager {
    class func documentsDir() -> String {
        var paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true) as [String]
        return paths[0]
    }

    class func cachesDir() -> String {
        var paths = NSSearchPathForDirectoriesInDomains(.CachesDirectory, .UserDomainMask, true) as [String]
        return paths[0]
    }
}

protocol AudioConcatenatorDelegate {
    func audioConcatenationDidComplete(success: Bool,destinationPath:String)
}

class AudioConcatenator {

    var delegate: AudioConcatenatorDelegate!
    var directory: NSString
    var namesStanza: [AVAsset: String] = Dictionary()

    init() {
        self.directory = NSFileManager.cachesDir()
    }

    init(fileDirectoryPath path: String, delegate: AudioConcatenatorDelegate) {
        self.delegate = delegate
        self.directory = path
    }

    func mergeCAFs(cafNames: [String]) -> Bool {

        var cafAssets:[AVAsset] = [AVAsset]()

        for name in cafNames {
            if let ass = assetForFileName(name) {
                cafAssets.append(ass)
            }
        }

        
        if !(cafAssets.count > 0) {
            return false
        }

        var comp: AVMutableComposition = AVMutableComposition()
        var previousAsset: AVAsset?
        var error = NSErrorPointer()
        var totalDuration : CMTime?
        var durationValue : CMTimeValue?
        for asset in cafAssets {
            let track: AVMutableCompositionTrack = comp.addMutableTrackWithMediaType(AVMediaTypeAudio, preferredTrackID: CMPersistentTrackID(kCMPersistentTrackID_Invalid))
            let tracks = asset.tracksWithMediaType(AVMediaTypeAudio)
            //if (tracks.count)>0{
                let audioTrack = tracks[0] as AVAssetTrack
                if(previousAsset != nil && (self.namesStanza[previousAsset!])! != (self.namesStanza[asset])!){
                    totalDuration = CMTimeMake(totalDuration!.value + durationValue!,asset.duration.timescale)
                    durationValue = asset.duration.value
                }
                else{
                    if(previousAsset != nil){
                        durationValue = max(asset.duration.value,durationValue!)
                        //totalDuration = CMTimeMake(totalDuration!.value + durationValue,totalDuration!.timescale)
                        
                    }
                    else{
                        totalDuration = kCMTimeZero
                        durationValue = asset.duration.value
                    }
                    
                }

                let startTime: CMTime = (previousAsset == nil ? kCMTimeZero : totalDuration!)

                track.insertTimeRange(
                    CMTimeRangeMake(kCMTimeZero, asset.duration),
                    ofTrack: audioTrack,
                    atTime: startTime,
                    error: error
                )
           
            /*
            if(previousAsset == nil){
                var durationValue = max(asset.duration.value,previousAsset!.duration.value)
                

            }
            else{
                //var prevStanza = self.namesStanza[previousAsset!]
                if((self.namesStanza[previousAsset!])! != (self.namesStanza[asset])!){
                    println("different")
                    totalDuration = CMTimeMake(totalDuration!.value + asset.duration.value, totalDuration!.timescale)
                }
                else{
                    println("same")
                    var durationValue = max(asset.duration.value,previousAsset!.duration.value)
                    totalDuration = CMTimeMake(totalDuration!.value + durationValue, totalDuration!.timescale)
                }
            }
            
           // }
*/

            previousAsset = asset
        }


        if let exportSession = AVAssetExportSession(asset: comp, presetName: AVAssetExportPresetAppleM4A) {

            let destinationPath = self.directory.stringByAppendingString("/concat.m4a")
            exportSession.outputURL = NSURL.fileURLWithPath(destinationPath)
            exportSession.outputFileType = AVFileTypeAppleM4A

            if !removeFileAtPath(destinationPath) {
                return false
            }

            exportSession.exportAsynchronouslyWithCompletionHandler({ () -> Void in

                switch(exportSession.status) {

                case .Waiting:
                    println("Waiting")
                    break
                case .Cancelled:
                    println("Cancelled")
                    break
                case .Exporting:
                    println("Exporting")
                    break
                case .Failed:
                    println("Failed")
                    self.delegate?.audioConcatenationDidComplete(false,destinationPath: destinationPath)
                    break
                case .Unknown:
                    println("Unknown")
                    break
                case .Completed:
                    println("Completed")
                    self.delegate?.audioConcatenationDidComplete(true,destinationPath: destinationPath)
                    break
                }
            })

            return true
        }
        else {
            return false
        }
    }


    private func assetForFileName(name: String) -> AVAsset! {
        
        var filePath = self.directory.stringByAppendingString("/\(name)")
        var fileURL = NSURL(fileURLWithPath: filePath)
        var avasset =  AVURLAsset.assetWithURL(fileURL) as AVAsset!
        var nameArr = name.componentsSeparatedByString("-")
        var stanza = nameArr[nameArr.count-1]
        namesStanza[avasset] = stanza
        return avasset

    }

    private func removeFileAtPath(path: String) -> Bool {
        let fileManager = NSFileManager.defaultManager()
        if fileManager.fileExistsAtPath(path) {
            var error = NSErrorPointer()
            if !fileManager.removeItemAtPath(path, error: error) {
                println("Error \(error)")
                return false
            }
            else {
                return true
            }
        }
        return true
    }
    
}