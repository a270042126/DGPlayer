//
//  ViewController.swift
//  DGPlayer
//
//  Created by dd on 2018/12/8.
//  Copyright © 2018年 dd. All rights reserved.
//

import UIKit
import AVKit

class ViewController: UIViewController {
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
   
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let vc = TestViewController()
        self.view.addSubview(vc.view)
       
        present(vc, animated: true, completion: nil)
    }
}

