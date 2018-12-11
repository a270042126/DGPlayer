//
//  DGPlayInfo.swift
//  DGPlayer
//
//  Created by dd on 2018/12/6.
//  Copyright © 2018年 dd. All rights reserved.
//

import UIKit

class DGPlayInfo: NSObject {

    var url: String = ""
    var artist: String = ""
    var title: String = ""
    var placeholder: String = ""
    
    init(dict: [String: String]) {
        self.url = dict["url"]!
        self.artist = dict["artist"]!
        self.title = dict["title"]!
        self.placeholder = dict["placeholder"]!
    }
}
