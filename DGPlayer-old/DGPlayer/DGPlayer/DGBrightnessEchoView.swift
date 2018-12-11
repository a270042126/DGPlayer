//
//  DGBrightnessEchoView.swift
//  DGPlayer
//
// 亮度

import UIKit

private let DGGRidCount = 16
class DGBrightnessEchoView: UIView {
    
    static let shareSingle = DGBrightnessEchoView()
    
    private lazy var gridArray: [UIView] = [UIView]()
    
    // UIToolbar用做毛玻璃背景
    private lazy var toolBar: UIToolbar = {
        let toolBar = UIToolbar()
        toolBar.backgroundColor = UIColor.lightGray
        toolBar.alpha = 0.9
        return toolBar
    }()
     // 亮度回显图标标题
    private lazy var titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.font = UIFont.systemFont(ofSize: 16)
        titleLabel.textColor = UIColor(red: 66/255.0, green: 66/255.0, blue: 66/255.0, alpha: 1)
        titleLabel.text = "亮度"
        return titleLabel
    }()
    // 亮度回显图标背景图片
    private lazy var bgImageView: UIImageView = {
        let bgImageView = UIImageView()
        bgImageView.image = UIImage(named: "playerBrightness")
        return bgImageView
    }()
    // 亮度回显图标进度条
    private lazy var brightnessProgressView: UIView = {
        let brightnessProgressView = UIView()
        brightnessProgressView.backgroundColor = UIColor(red: 66/255.0, green: 66/255.0, blue: 66/255.0, alpha: 1)
        return brightnessProgressView
    }()
    // 亮度回显图标进度条
    private var currentBrightness: CGFloat = 0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.cornerRadius = 10
        clipsToBounds = true
        alpha = 0
        addSubview(toolBar)
        addSubview(titleLabel)
        addSubview(bgImageView)
        addSubview(brightnessProgressView)
        // KVO 监控亮度的变化
        UIScreen.main.addObserver(self, forKeyPath: "brightness", options: .new, context: nil)
        setupBrightnessGrid()
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "brightness"{
            if let newValue = change?[.newKey] as? CGFloat{
                updateBrightnessGrid(brightness: newValue)
            }
        }
    }
    
    deinit {
        removeObserver(UIScreen.main, forKeyPath: "brightness")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // toolbar毛玻璃背景布局
        toolBar.frame = bounds
        
         // 标题布局
        let titleLabelX: CGFloat = 0
        let titleLabelY: CGFloat = 5
        let titleLabelW = bounds.size.width
        let titleLabelH: CGFloat = 30
        titleLabel.frame = CGRect(x: titleLabelX, y: titleLabelY, width: titleLabelW, height: titleLabelH)
       
        // 亮度图标布局
        let bgImageViewX: CGFloat = 38
        let bgImageViewY = titleLabel.frame.maxY + 5
        let bgImageViewW: CGFloat = 79
        let bgImageViewH: CGFloat = 76
        bgImageView.frame = CGRect(x: bgImageViewX, y: bgImageViewY, width: bgImageViewW, height: bgImageViewH)
        
        // 亮度进度条布局
        var brightnessProgressViewRect = brightnessProgressView.frame
        brightnessProgressViewRect.origin.x = 12
        brightnessProgressViewRect.origin.y = bgImageView.frame.maxY + 16
        brightnessProgressViewRect.size.width = bounds.size.width - 2 * 12
        brightnessProgressViewRect.size.height = 7
        brightnessProgressView.frame = brightnessProgressViewRect
        
        // 亮度进度条内小格子布局
        let gridW = (brightnessProgressView.bounds.size.width - CGFloat(DGGRidCount + 1)) / CGFloat(DGGRidCount)
        let gridH: CGFloat = 5
        let gridY: CGFloat = 1
        for index in 0...DGGRidCount{
            let gridX = CGFloat(index) * (gridW + 1) + 1
            let gridView = gridArray[index]
            gridView.frame = CGRect(x: gridX, y: gridY, width: gridW, height: gridH)
        }
    }
    
    private func setupBrightnessGrid(){
        for _ in 0...DGGRidCount{
            let grid = UIView()
            grid.backgroundColor = UIColor.white
            self.brightnessProgressView.addSubview(grid)
            gridArray.append(grid)
        }
        
    }
    
    // 更新亮度回显
    private func updateBrightnessGrid(brightness: CGFloat){
        let stage: CGFloat = 1 / CGFloat(DGGRidCount)
        let level = brightness / stage
        for index in 0...gridArray.count - 1{
            let grid = gridArray[index]
            if CGFloat(index) <= level{
                grid.isHidden = false
            }else{
                grid.isHidden = true
            }
        }
    }
}


