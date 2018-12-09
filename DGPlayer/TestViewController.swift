//
//  TestViewController.swift
//  DGPlayer
//
//  Created by dd on 2018/12/8.
//  Copyright © 2018年 dd. All rights reserved.
//

import UIKit

class TestViewController: UIViewController {

    let playerVC = DGPlayerViewController()
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        addChild(playerVC)
        self.view.addSubview(playerVC.view)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        playerVC.view.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.width * 9 / 16)
    }

}
