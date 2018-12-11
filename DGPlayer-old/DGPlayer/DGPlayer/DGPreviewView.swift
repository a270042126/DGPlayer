//
//  DGPlayerView.swift
//  DGPlayer
//
//  Created by dd on 2018/12/6.
//  Copyright © 2018年 dd. All rights reserved.
//

import UIKit

class DGPreviewView: UIView {
    
    static let shareSingle = DGPreviewView()

    // 视频缩略图
    private lazy var previewImageView: UIImageView = {
        let previewImageView = UIImageView()
        previewImageView.layer.masksToBounds = true
        previewImageView.clipsToBounds = true
        previewImageView.layer.cornerRadius = 5
        previewImageView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
        return previewImageView
    }()
    
    // 进度标签
    private lazy var previewtitleLabel: UILabel = {
        let previewtitleLable = UILabel()
        previewtitleLable.textAlignment = .center
        previewtitleLable.font = UIFont.systemFont(ofSize: 20)
        previewtitleLable.textColor = UIColor.white
        return previewtitleLable
    }()
    
    // 等待菊花
    private lazy var loadingView: UIActivityIndicatorView = {
        let loadingView = UIActivityIndicatorView()
        loadingView.style = .white
        loadingView.hidesWhenStopped = true
        return loadingView
    }()
    
    lazy var progressView: UIProgressView = {
        let progressView = UIProgressView()
        progressView.trackTintColor = UIColor.white
        progressView.progressTintColor = UIColor.red
        return progressView
    }()
    
    var image: UIImage?{
        didSet{
            if image == nil {
                self.loadingView.startAnimating()
                self.previewImageView.image = nil
            } else {
                self.loadingView.stopAnimating()
                self.previewImageView.image = image
            }
        }
    }
    
    var time: TimeInterval = 0 {
        didSet{
            self.previewtitleLabel.text = String(format: "%02ld:%02ld", Int(time)/60,Int(time)%60)
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if traitCollection.verticalSizeClass == UIUserInterfaceSizeClass.regular{
            // 转至竖屏
            self.previewImageView.isHidden = true
            self.progressView.isHidden = false
        }else if traitCollection.verticalSizeClass == UIUserInterfaceSizeClass.compact{
            // 转至横屏
            self.previewImageView.isHidden = false
            self.progressView.isHidden = true
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(previewImageView)
        addSubview(previewtitleLabel)
        previewImageView.addSubview(loadingView)
        addSubview(progressView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let previewImageViewX: CGFloat = 0
        let previewImageViewY: CGFloat = 0
        let previewImageViewW = self.bounds.width
        let previewImageViewH = self.bounds.width * 9 / 16
        previewImageView.frame = CGRect(x: previewImageViewX, y: previewImageViewY, width: previewImageViewW, height: previewImageViewH)
        
        let previewtitleLabelX: CGFloat = 0
        let previewtitleLabelY: CGFloat = 110
        let previewtitleLabelW = self.bounds.width
        let previewtitleLabelH: CGFloat = 20
        previewtitleLabel.frame = CGRect(x: previewtitleLabelX, y: previewtitleLabelY, width: previewtitleLabelW, height: previewtitleLabelH)
        
        let loadingViewWH: CGFloat = 20
        let loadingViewX = (self.bounds.width - loadingViewWH) * 0.5
        let loadingViewY = (self.bounds.height - loadingViewWH) * 0.5
        loadingView.frame = CGRect(x: loadingViewX, y: loadingViewY, width: loadingViewWH, height: loadingViewWH)
        
        let progressViewWH: CGFloat = 100
        let progressViewX = (self.bounds.width - progressViewWH) * 0.5
        let progressViewY = (self.bounds.height - progressViewWH) * 0.5
        progressView.frame = CGRect(x: progressViewX, y: progressViewY, width: progressViewWH, height: progressViewWH)
    }
}
