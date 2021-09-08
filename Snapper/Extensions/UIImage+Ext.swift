//
//  UIImage+Ext.swift
//  Snapper
//
//  Created by Lefdili Alaoui Ayoub on 29/8/2021.
//

import UIKit

extension UIImage {

    func saveToDocuments(savingFolder:URL, globalName: String) -> URL? {
        
        let fileURL = savingFolder.appendingPathComponent("\(globalName).png")
                
        if let data = self.jpegData(compressionQuality: 1.0) {
                try? data.write(to: fileURL, options: .atomicWrite)
                return fileURL
        }
        return nil
    }

    func imageWithSize(_ size:CGSize) -> UIImage {
        var scaledImageRect = CGRect.zero
        
        let aspectWidth:CGFloat = size.width / self.size.width
        let aspectHeight:CGFloat = size.height / self.size.height
        let aspectRatio:CGFloat = min(aspectWidth, aspectHeight)
        
        scaledImageRect.size.width = self.size.width * aspectRatio
        scaledImageRect.size.height = self.size.height * aspectRatio
        scaledImageRect.origin.x = (size.width - scaledImageRect.size.width) / 2.0
        scaledImageRect.origin.y = (size.height - scaledImageRect.size.height) / 2.0
        
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        
        self.draw(in: scaledImageRect)
        
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return scaledImage!
    }

}
