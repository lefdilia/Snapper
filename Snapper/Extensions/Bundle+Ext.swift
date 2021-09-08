//
//  Bundle+Ext.swift
//  Snapper
//
//  Created by Lefdili Alaoui Ayoub on 27/8/2021.
//

import Foundation


extension Bundle {
    var appName: String? {
        return object(forInfoDictionaryKey: "CFBundleName") as? String
    }
    
    var appVersion: String? {
        return object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
    }
    
    var buildNumber: String? {
        return object(forInfoDictionaryKey: "CFBundleVersion") as? String
    }
}
