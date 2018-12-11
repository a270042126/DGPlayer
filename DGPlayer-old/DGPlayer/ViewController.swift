//
//  ViewController.swift
//  DGPlayer
//
//  Created by dd on 2018/12/6.
//  Copyright © 2018年 dd. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    override var shouldAutorotate: Bool{
        get{
            return true
        }
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask{
        get{
            return .all
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        let playInfos = DGVideoTool.shareSingle.playInfos()
        let playView = DGPlayerView.loadFromNib()
        
        playView.playWithPlayInfo(playInfo: playInfos.first!)
        self.view.addSubview(playView)
    }

    
}

