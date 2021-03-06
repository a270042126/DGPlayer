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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        playerView.delegate = self
        playerView.setupPlay(urlStr: "http://www.crowncake.cn:18080/wav/no.9.mp4")
        self.view.addSubview(playerView)
        playerView.snp.makeConstraints { (make) in
            make.top.left.right.bottom.equalToSuperview()
        }
    }
    
//    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
//         print("willTransition")
//        let orientation = UIDevice.current.orientation
//        onDeviceOrientation(orientation)
//    }
//
//    private func onDeviceOrientation(_ orientation: UIDeviceOrientation){
////        playerView.snp.removeConstraints()
////        playerView.removeFromSuperview()
////        if orientation.isPortrait {
////            isFullScreen = false
////            self.view.addSubview(playerView)
////        } else if orientation.isLandscape {
////            isFullScreen = true
////            UIApplication.shared.keyWindow?.rootViewController?.view.addSubview(playerView)
////        }
////        playerView.snp.makeConstraints { (make) in
////            make.top.left.right.bottom.equalToSuperview()
////        }
//    }
    
    private var isLandscape: Bool = false {
        didSet{
            UIApplication.changeOrientationTo(landscape: isLandscape)
        }
    }
    
    private func setDeviceOrientation(_ orientation: UIDeviceOrientation){
        UIDevice.current.setValue(orientation.rawValue, forKey: "orientation")
    }
    
    func playPause(){
        
    }
}

extension DGPlayerViewController: DGPlayerViewDelegate{
    
    func dgplayerViewRotateButtonClicked() {
       isLandscape = !isLandscape
    }
}
