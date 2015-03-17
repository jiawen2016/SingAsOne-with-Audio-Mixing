//
//  WriteDataToFile.swift
//  SingAsOne
//
//  Created by LaParure on 3/13/15.
//  Copyright (c) 2015 Jia Wen Li. All rights reserved.
//

import Foundation
class WriteDataToFile{
    func getFilePath(fileName:String,dirName: String) ->String{
        var documentPath = getDocumentPath()
        if dirName.isEmpty{
            return documentPath.stringByAppendingPathComponent(fileName)
        }
        else{
            return documentPath.stringByAppendingPathComponent("\(dirName)/\(fileName)")
        }
    }
 
    func creatFileAtPath(isDirectory: Bool, fileName: String, dirName: String) ->Bool{
        var filePath = getFilePath(fileName,dirName: dirName)
        if isDirectory{
            return NSFileManager.defaultManager().createDirectoryAtPath(filePath, withIntermediateDirectories: true, attributes: nil, error: nil)
        }
        else{
           return NSFileManager.defaultManager().createFileAtPath(filePath, contents: nil, attributes: nil)
        }
    }

    func writeData(content:AnyObject,fileName:String,dirName:String)->String{
        var filePath = getFilePath(fileName, dirName: dirName)
        let url = NSURL(fileURLWithPath: filePath)
        println(url)
        var error: NSError?
        if((content as NSData).writeToFile(filePath, options:NSDataWritingOptions.DataWritingAtomic, error:&error)){
            
        }
        else{
            println(error)
        }
        
        return filePath
        
    }
   
    private func getDocumentPath() ->String{
        let application = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask,true)
        return application[0] as String
    }
    
}
