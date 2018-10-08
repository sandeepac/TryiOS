//
//  LocalImages.swift
//  Tully Dev
//
//  Created by Apple on 24/09/18.
//  Copyright © 2018 Tully. All rights reserved.
//

import Foundation

class LocalImages {
    
    static let dateFormat = "yyyymmdd-HH:mm:ss"
    static let fileManager = FileManager.default
    static let paths = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
    static let documentsURL = paths[0]
    static let imageFolderPath = "tully/images/Tully_File_"
    static let documentFolderPath = "tully/documents/Tully_File_"
    static let mimeTypeImage = "png"
    
    class func createTullyFolder() {
        
        
        let documentsPath = documentsURL.appendingPathComponent("tully/documents")
        let imagesPath = documentsURL.appendingPathComponent("tully/images")
        
        if !fileManager.fileExists(atPath: documentsPath.path) && !fileManager.fileExists(atPath: imagesPath.path) {
            
            do
            {
                try fileManager.createDirectory(atPath: documentsPath.path, withIntermediateDirectories: true, attributes: nil)
                try fileManager.createDirectory(atPath: imagesPath.path, withIntermediateDirectories: true, attributes: nil)
            }
            catch let error as NSError
            {
                NSLog("Unable to create directory \(error.debugDescription)")
            }
        }
    }
    
    class func saveImage(url: URL, timestamp: Int64) {
        
        DispatchQueue.global(qos: .background).async {
            
            let data = try? Data(contentsOf: url)
            
            if let imageData = data {
                
                let image = UIImage(data: imageData)
                
                do {
                    
                    let formattedDate = getFormattedDate(timestamp: timestamp)
                    
                    let fileURL = documentsURL.appendingPathComponent("\(imageFolderPath)\(formattedDate).png")
                    
                    if let pngImageData = UIImagePNGRepresentation(image!) {
                        
                        if !fileManager.fileExists(atPath: fileURL.path) {
                            
                            try pngImageData.write(to: fileURL, options: .atomic)
                        }
                    }
                } catch { }
            }
        }
    }
    
    class func saveDocuments(url: URL, timestamp: Int64, mimeType: String, completion: @escaping (Bool) -> Swift.Void) {
        
        DispatchQueue.global(qos: .background).async {
            
            let formattedDate = getFormattedDate(timestamp: timestamp)
            
            let fileURL = documentsURL.appendingPathComponent("\(documentFolderPath)\(formattedDate).\(mimeType)")
            
            let datapdf = try? Data(contentsOf: url)
            
            if let aDatapdf = datapdf {
                
                if !fileManager.fileExists(atPath: fileURL.path) {
                    
                    try? aDatapdf.write(to: fileURL, options: .atomic)
                    completion(true)
                }
            }
        }
    }
    
    class func checkIsFileExist(timestamp: Int64, mimeType: String) -> Bool {
        
        var isFileExist = false
        
        let formattedDate = getFormattedDate(timestamp: timestamp)
        
        var fileURL : URL?
        
        if mimeType == mimeTypeImage {
            
            fileURL = documentsURL.appendingPathComponent("\(imageFolderPath)\(formattedDate).png")
        }
        else {
            
            fileURL = documentsURL.appendingPathComponent("\(documentFolderPath)\(formattedDate).\(mimeType)")
        }
        
        if fileManager.fileExists(atPath: (fileURL?.path)!) {
            
            isFileExist = true
        }
        
        return isFileExist
    }
    
    class func getFilePath(timestamp: Int64, mimeType: String) -> String {
        
        let formattedDate = getFormattedDate(timestamp: timestamp)
        
        var fileURL : URL?
        
        if mimeType == mimeTypeImage {
            
            fileURL = documentsURL.appendingPathComponent("\(imageFolderPath)\(formattedDate).png")
        }
        else {
            
            fileURL = documentsURL.appendingPathComponent("\(documentFolderPath)\(formattedDate).\(mimeType)")
        }
        
        return (fileURL?.path)!
    }
    
    class func getFormattedDate(timestamp : Int64) -> String {
        
        let timeInSeconds = Double(timestamp) / 1000
        
        let date = Date(timeIntervalSince1970: TimeInterval(timeInSeconds))
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(abbreviation: Calendar.current.timeZone.abbreviation()!) //Set timezone that you want
        dateFormatter.locale = NSLocale.current
        dateFormatter.dateFormat = dateFormat //Specify your format that you want
        let strDate = dateFormatter.string(from: date)
        
        return strDate
    }
}
