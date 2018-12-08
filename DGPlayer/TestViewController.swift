//
//  TestViewController.swift
//  DGPlayer
//
//  Created by dd on 2018/12/8.
//  Copyright © 2018年 dd. All rights reserved.
//

import UIKit

class TestViewController: UIViewController {

    let playView = DGPlayView()
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        playView.setupPlay(urlStr: "http://www.crowncake.cn:18080/wav/no.9.mp4")
        self.view.addSubview(playView)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        playView.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.width * 9 / 16)
    }

}
