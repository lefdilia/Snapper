//
//  AppConfig.swift
//  Snapper
//
//  Created by Lefdili Alaoui Ayoub on 28/8/2021.
//

import Foundation


class appConfiguration {
    
    let _name = "Snapper"
    let _sharedMsgTitle = "Snapper Image"

}

class userDefaultKeys {
    
    let _SettingsKey = "Settings"
    let _highResolutionKey = "highResolution"
    let _autoSaveToPhotosKey = "autoSaveToPhotos"

    let _SettingsDefault: [String : Any] = [
                "defaultCamera": "Front",
                     "timer": 4,
                     "orientation": "Horizontal",
                     "numberOfPhotos": 4]
}

class defaultData {
    
    let timer = [2, 4, 6, 8, 10, 15, 20]
    let photos = [2, 4, 6, 8, 10]
    let orientation = ["Vertical", "Horizontal"]
    let defaultCamera = ["Front", "Back"]
    
}

struct AppConfig {
    
    static let appKeys = userDefaultKeys()
    static let appData = defaultData()
    static let initial = appConfiguration()
    
}

