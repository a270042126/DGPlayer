//
//  PlayerView.swift
//  DGPlayer
//
//  Created by dd on 2018/12/8.
//  Copyright © 2018年 dd. All rights reserved.
//

import UIKit
import SnapKit


class DGBottomView: UIView {

    
    var currentTime: TimeInterval = 0{
        didSet{
            currentTimeLabel.text = String(format: "%02ld:%02ld", Int(currentTime)/60,Int(currentTime)%60)
            progressSlider.value = Float(currentTime)
        }
    }
    
    var totalTime: TimeInterval = 0{
        didSet{
            totalTimeLabel.text = String(format: "%02ld:%02ld", Int(totalTime)/60,Int(totalTime)%60)
            progressSlider.maximumValue = Float(totalTime)
        }
    }
    
    lazy var playButton: UIButton = { [unowned self] in
        let button = UIButton()
        button.setImage(UIImage(named: "Play"), for: .selected)
        button.setImage(UIImage(named: "Stop"), for: .normal)
        return button
    }()
    
    lazy var rotateButton: UIButton = { [unowned self] in
        let button = UIButton()
        button.setImage(UIImage(named: "Rotation"), for: .normal)
        return button
    }()
    
    lazy var loadedView: UIProgressView = {
        let progress = UIProgressView()
        progress.progressTintColor = UIColor(red: 167 / 255.0, green: 167 / 255.0, blue: 167 / 255.0, alpha: 1)
        progress.progress = 0
        return progress
    }()
    
    lazy var progressSlider: UISlider = { [unowned self] in
        let slider = UISlider()
        slider.minimumValue = 0
        slider.maximumValue = 0
        slider.minimumTrackTintColor = UIColor.red
        slider.maximumTrackTintColor = UIColor.clear
        slider.setThumbImage(UIImage(named: "icmpv_thumb_light"), for: .normal)
        return slider
        }()
    
    lazy var distinctButton: UIButton = { [unowned self] in
        let button = UIButton()
        button.setTitle("高清", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        button.isHidden = true
        return button
        }()
    
    private lazy var currentTimeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = UIColor.white
        label.text = "00:00"
        return label
    }()
    
    private lazy var totalTimeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = UIColor.white
        label.text = "00:00"
        return label
    }()
    
    private lazy var backgroundImageView: UIImageView = UIImageView(image: UIImage(named: "video_mask_bottom"))

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if distinctButton.isHidden{
            distinctButton.snp.updateConstraints { (make) in
                make.right.equalTo(rotateButton.snp.left).offset(0)
                make.width.equalTo(0)
            }
        }else{
            distinctButton.snp.updateConstraints { (make) in
                make.right.equalTo(rotateButton.snp.left).offset(-8)
                make.width.equalTo(30)
            }
        }
    
        let progressW = totalTimeLabel.frame.minX - currentTimeLabel.frame.maxX - 16
        progressSlider.frame.size.width = progressW
        loadedView.frame.size.width = progressW
    }
    
    private func setupUI(){
        addSubview(backgroundImageView)
        addSubview(playButton)
        addSubview(currentTimeLabel)
        addSubview(rotateButton)
        addSubview(distinctButton)
        addSubview(totalTimeLabel)
        addSubview(loadedView)
        addSubview(progressSlider)
        
        playButton.snp.makeConstraints { (make) in
            make.width.equalTo(31)
            make.height.equalTo(40)
            make.left.equalToSuperview().offset(0)
            make.centerY.equalToSuperview()
        }
        
        currentTimeLabel.snp.makeConstraints { (make) in
            make.width.equalTo(40)
            make.height.equalTo(11)
            make.left.equalTo(playButton.snp.right).offset(0)
            make.centerY.equalToSuperview()
        }
        
        rotateButton.snp.makeConstraints { (make) in
            make.width.equalTo(30)
            make.height.equalTo(33)
            make.right.equalToSuperview().offset(-10)
            make.centerY.equalToSuperview()
        }
        
        distinctButton.snp.makeConstraints { (make) in
            make.width.equalTo(30)
            make.height.equalTo(20)
            make.right.equalTo(rotateButton.snp.left).offset(-8)
            make.centerY.equalToSuperview()
        }
        
        totalTimeLabel.snp.makeConstraints { (make) in
            make.width.equalTo(40)
            make.height.equalTo(11)
            make.right.equalTo(distinctButton.snp.left).offset(-8)
            make.centerY.equalToSuperview()
        }
        
        progressSlider.snp.makeConstraints { (make) in
            make.left.equalTo(currentTimeLabel.snp.right).offset(8)
            make.centerY.equalToSuperview().offset(-1)
        }
        
        loadedView.snp.makeConstraints { (make) in
            make.height.equalTo(2)
            make.left.equalTo(currentTimeLabel.snp.right).offset(8)
            make.centerY.equalToSuperview()
        }
        
        backgroundImageView.snp.makeConstraints { (make) in
            make.top.left.right.bottom.equalToSuperview()
        }
    }
}

