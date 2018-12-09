//
//  ViewController.swift
//  DGPlayer
//
//  Created by dd on 2018/12/8.
//  Copyright © 2018年 dd. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var testView: UIView = UIView()
    var viewFrame: CGRect = CGRect()
    var parentView:UIView?
    var isFullScreen = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        testView.backgroundColor = UIColor.orange
        testView.frame = CGRect(x: 100, y: 100, width: 100, height: 100)
        self.view.addSubview(testView)
        let tap = UITapGestureRecognizer(target: self, action: #selector(clicked))
        testView.addGestureRecognizer(tap)
        
        let testView2 = UIView()
        testView2.backgroundColor = UIColor.gray
        testView.addSubview(testView2)
        testView2.frame = CGRect(x: 10, y: 10, width: 20, height: 20)
    }
    
    @objc func clicked(){
        if(!isFullScreen){
            parentView = testView.superview
            viewFrame = testView.frame
            
            let rectInWindow = self.view.convert(self.view.bounds, to: UIApplication.shared.keyWindow)
            testView.removeFromSuperview()
            UIApplication.shared.keyWindow?.addSubview(testView)
            testView.frame = rectInWindow
            testView.snp.makeConstraints { [unowned self] (make)  in
                make.width.equalTo(self.testView.superview!.bounds.width)
                make.height.equalTo(self.testView.superview!.bounds.height)
            }
            testView.backgroundColor = UIColor.red
            
        }else{
            testView.removeFromSuperview()
            testView.backgroundColor = UIColor.green
            parentView?.addSubview(testView)
            let frame = self.parentView!.convert(self.viewFrame, to: UIApplication.shared.keyWindow)
            testView.snp.remakeConstraints({ (make) in
                make.width.equalTo(frame.width)
                make.height.equalTo(frame.height)
            })
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.navigationController?.pushViewController(TestViewController(), animated: true)
        
    }
  
}

