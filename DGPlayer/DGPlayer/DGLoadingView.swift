//
//  DGLoadingView.swift
//  DGPlayer
//
//  Created by dd on 2018/12/7.
//  Copyright © 2018年 dd. All rights reserved.
//

import UIKit

class DGLoadingView: UIView {
    
    var isHidesWhenStopped = false {
        didSet{
            if isHidesWhenStopped{
                stopAnimating()
            }else{
                startAnimating()
            }
        }
    }

    private lazy var activityIndicator: UIImageView = {
        let activityIndicator = UIImageView(image: UIImage(named: "loading"))
        activityIndicator.backgroundColor = UIColor.clear
        return activityIndicator
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(activityIndicator)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let activityIndicatorWH: CGFloat = 50
        let activityIndicatorX = (self.bounds.width - activityIndicatorWH) * 0.5
        let activityIndicatorY = (self.bounds.height - activityIndicatorWH) * 0.5
        activityIndicator.frame = CGRect(x: activityIndicatorX, y: activityIndicatorY, width: activityIndicatorWH, height: activityIndicatorWH)
    }
}

extension DGLoadingView{
    
    public func startAnimating(){
         let animation = CABasicAnimation(keyPath: "transform.rotation.z")
        animation.fromValue = 0
        animation.toValue = CGFloat.pi * 2
        animation.duration = 1
        animation.autoreverses = false
        animation.fillMode = .forwards
        animation.repeatCount = MAXFLOAT
        activityIndicator.layer.add(animation, forKey: nil)
        activityIndicator.isHidden = false
    }
    
    public func stopAnimating(){
        activityIndicator.layer.removeAllAnimations()
        activityIndicator.isHidden = true
    }
}
