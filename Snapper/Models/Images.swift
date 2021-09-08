//
//  Image.swift
//  Snapper
//
//  Created by Lefdili Alaoui Ayoub on 19/8/2021.
//

import Foundation

struct Images {
    
    var thumbnail: URL?
    var path: URL?
    var originalName: String?
    var name: String
    var size: String?
    var creationDate: String
    
    init(thumbnail:URL?, path:URL?, originalName: String?, name: String, size: String?, creationDate: String) {
        self.thumbnail = thumbnail
        self.path = path
        self.originalName = originalName
        self.name = name
        self.size = size
        self.creationDate = creationDate
    }
    
}
