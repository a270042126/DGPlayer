//
//  BrightnessAndVolumeView.swift
//  DGPlayer
//
//

import UIKit
import MediaPlayer
import AVFoundation

enum DGMoveType{
    case moveTypePortrait  // 竖向滑动手势
    case moveTypeLandscape // 横向滑动手势
    case moveTypeUnknow // 未知手势
}

private let DGProgressScale = 8
class DGBrightnessAndVolumeView: UIView {
    
    static let shareSingle = DGBrightnessAndVolumeView()
    
    var progressChangeHandle: ((CGFloat)->())?
    var progressLandscapeEnd: (()->())?
    var progressPortraitEnd: (()->())?
    
    //左边一半的亮度调节的View
    private lazy var brightnessView: UIView = {
        let brightnessView = UIView()
        brightnessView.backgroundColor = UIColor.clear
        brightnessView.translatesAutoresizingMaskIntoConstraints = false
        return brightnessView
    }()
    
     // 右边的音量调节的View
    private lazy var volumeView: UIView = {
       let volumeView = UIView()
        volumeView.backgroundColor = UIColor.clear
        volumeView.translatesAutoresizingMaskIntoConstraints = false
        return volumeView
    }()
    
    //音量回显图标
    private lazy var brightnessEchoView:UIView = DGBrightnessEchoView.shareSingle
    
    private var currentBrightnessValue:CGFloat = 0
    private var currentVolumeValue: Float = 0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(brightnessView)
        addSubview(volumeView)
        addSubview(brightnessEchoView)
        addPanGesture()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
           // 布局亮度调节View
        let brightnessViewX: CGFloat = 0
        let brightnessViewY: CGFloat = 0
        let brightnessViewW: CGFloat = self.bounds.width * 0.5
        let brightnessViewH: CGFloat = self.bounds.height
        brightnessView.frame = CGRect(x: brightnessViewX, y: brightnessViewY, width: brightnessViewW, height: brightnessViewH)
        
        // 布局BrightnessEchoView
        let brightnessEchoViewWH: CGFloat = 155
        let brightnessEchoViewX = (self.bounds.width - brightnessEchoViewWH) * 0.5
        let brightnessEchoViewY = (self.bounds.height - brightnessEchoViewWH) * 0.5
        brightnessEchoView.frame = CGRect(x: brightnessEchoViewX, y: brightnessEchoViewY, width: brightnessEchoViewWH, height: brightnessEchoViewWH)
        
        // 布局音量调节View
        let volumeViewX: CGFloat = 0
        let volumeViewY: CGFloat = 0
        let volumeViewW = self.bounds.width * 0.5
        let volumeViewH = self.bounds.height
        volumeView.frame = CGRect(x: volumeViewX, y: volumeViewY, width: volumeViewW, height: volumeViewH)
    }
    
    deinit {
        UIScreen.main.removeObserver(self, forKeyPath: "brightness")
    }
}

extension DGBrightnessAndVolumeView{
    
    
    //添加手势
    private func addPanGesture(){
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(decideWhatToChange(sender:)))
        addGestureRecognizer(panGesture)
    }
    
    // 通过相应的手势执行相应的操作
    @objc private func decideWhatToChange(sender: UIPanGestureRecognizer){
        let point = sender.location(in: self)
        if judgeMoveType(sender: sender) == DGMoveType.moveTypePortrait{
            if brightnessView.frame.contains(point) {
                brightnessChange(sender: sender)
            }else if volumeView.frame.contains(point){
                volumeChange(sender: sender)
            }
        } else if judgeMoveType(sender: sender) == DGMoveType.moveTypeLandscape{
            progressChange(sender: sender, hander: progressChangeHandle)
        } else if judgeMoveType(sender: sender) == .moveTypeUnknow {return}
        
        if sender.state == UIGestureRecognizer.State.ended{
            if judgeMoveType(sender: sender) == DGMoveType.moveTypePortrait{
                progressPortraitEnd?()
            }
            
            if judgeMoveType(sender: sender) == DGMoveType.moveTypeLandscape{
                progressLandscapeEnd?()
            }
        }
    }
    
    private func progressChange(sender: UIPanGestureRecognizer, hander: ((CGFloat)->())?){
        let panPoint = sender.translation(in: brightnessView)
        let delta = panPoint.x / CGFloat(DGProgressScale)
        hander?(delta)
    }
    
    private func brightnessChange(sender: UIPanGestureRecognizer){
        let screenWidth = UIScreen.main.bounds.width
        let panPoint = sender.translation(in: brightnessView)
        let delta = -panPoint.y / screenWidth
        
        currentBrightnessValue = UIScreen.main.brightness
        if currentBrightnessValue < 0 {currentBrightnessValue = 0}
        UIScreen.main.brightness = currentBrightnessValue + delta
        UIView.animate(withDuration: 0.2, animations: {
            self.showBrightnessEchoView()
        }) { (_) in
            self.autoFadeoutBrightnessEchoView()
        }
    }
    
    private func showBrightnessEchoView(){
        brightnessEchoView.alpha = 1
    }
    
    private func autoFadeoutBrightnessEchoView(){
        NSObject.cancelPreviousPerformRequests(withTarget: self)
        self.perform(#selector(hideBrightnessEchoView), with: self, with: 3)
    }
    
    @objc private func hideBrightnessEchoView(){
        UIView.animate(withDuration: 0.5) {
            self.brightnessEchoView.alpha = 0
        }
    }
    
    // 通过pan拖拽时的移动位置的绝对值判断手势类型 |pointT.x| > |pointT.y| 横向手势  |pointT.y| < |pointT.x| 竖向手势
    private func judgeMoveType(sender: UIPanGestureRecognizer) -> DGMoveType{
        let poinT = sender.translation(in: self)
        let deltaTX = abs(poinT.x)
        let deltaTY = abs(poinT.y)
        if max(deltaTX, deltaTY) < 20 {return DGMoveType.moveTypeUnknow}
        if deltaTX > deltaTY {
            return DGMoveType.moveTypeLandscape
        } else {
            return DGMoveType.moveTypePortrait
        }
    }
    
    private func volumeChange(sender: UIPanGestureRecognizer){
        let screenWidth = UIScreen.main.bounds.width
        let panPoint = sender.translation(in: volumeView)
        let delta = -panPoint.x / screenWidth
        let sysVolumeView = MPVolumeView()
        //sysVolumeView.userActivity
        
        var sysVolumeSlider: UISlider? = nil
        for newView in sysVolumeView.subviews{
            if NSStringFromClass(newView.classForCoder) == "MPVolumeSlider"{
                sysVolumeSlider = newView as? UISlider
                break
            }
        }
        
        currentVolumeValue = Float(AVAudioSession.sharedInstance().outputVolume)
        sysVolumeSlider?.value = currentVolumeValue + Float(delta)
        if sysVolumeSlider!.value < 0 {sysVolumeSlider?.value = 0}
    }
}
