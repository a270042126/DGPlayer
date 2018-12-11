//
//  DGVideoTool.swift
//  DGPlayer
//
//  Created by dd on 2018/12/6.
//  Copyright © 2018年 dd. All rights reserved.
//

import UIKit

class DGVideoTool: NSObject {
    static var shareSingle = DGVideoTool()
    
    func playInfos() -> [DGPlayInfo]{
        let plistPath = Bundle.main.path(forResource: "playList", ofType: "plist")
        let data = NSArray(contentsOfFile: plistPath!)
        return data!.compactMap({DGPlayInfo(dict: $0 as! [String: String])})
    }
}
