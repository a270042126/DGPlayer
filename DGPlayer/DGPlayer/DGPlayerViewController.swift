//
//  PlayerViewController.swift
//  DGPlayer
//
//  Created by dd on 2018/12/8.
//  Copyright © 2018年 dd. All rights reserved.
//

import UIKit

class DGPlayerViewController: UIViewController {
    
    private lazy var playerView = DGPlayerView()
    private var isFullScreen = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        playerView.delegate = self
        playerView.setupPlay(urlStr: "http://www.crowncake.cn:18080/wav/no.9.mp4")
        self.view.addSubview(playerView)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        playerView.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.width * 9 / 16)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
   
    
//    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
//        let orientation = UIDevice.current.orientation
//        onDeviceOrientation(orientation)
//    }
//
//    private func onDeviceOrientation(_ orientation: UIDeviceOrientation){
//        playerView.snp.removeConstraints()
//        playerView.removeFromSuperview()
//        if orientation.isPortrait {
//            isFullScreen = false
//            self.view.addSubview(playerView)
//        } else if orientation.isLandscape {
//            isFullScreen = true
//            UIApplication.shared.keyWindow?.rootViewController?.view.addSubview(playerView)
//        }
//        playerView.snp.makeConstraints { (make) in
//            make.top.left.right.bottom.equalToSuperview()
//        }
//    }
    
    func playPause(){
        
    }
}

extension DGPlayerViewController: DGPlayerViewDelegate{
    
    func dgplayerViewRotateButtonClicked() {
//        let deviceType = UIDevice.current.model
//        if !isFullScreen{
//            if deviceType == "iPad"{
//                isFullScreen = true
//                onDeviceOrientation(.landscapeRight)
//            }else{
//                DeviceTool.interfaceOrientation(.landscapeRight)
//            }
//        }else{
//            if deviceType == "iPad"{
//                isFullScreen = false
//                onDeviceOrientation(.portrait)
//            }else{
//                DeviceTool.interfaceOrientation(.portrait)
//            }
//        }
        
    }
}
