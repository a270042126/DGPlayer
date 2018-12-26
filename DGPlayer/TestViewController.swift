//
//  TestViewController.swift
//  DGPlayer
//
//  Created by dd on 2018/12/8.
//  Copyright © 2018年 dd. All rights reserved.
//

import UIKit

class TestViewController: UIViewController {
    
    override var shouldAutorotate: Bool{
        get{
            return true
        }
    }

    let playerVC = DGPlayerViewController()
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        addChild(playerVC)
        self.view.addSubview(playerVC.view)
        playerVC.view.snp.makeConstraints { (make) in
            make.edges.equalToSuperview().inset(UIEdgeInsets.zero)
        }
//        let value = UIInterfaceOrientation.landscapeLeft.rawValue
//        playerVC.view.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.width * 9 / 16)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
    }

}
