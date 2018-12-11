//
//  DGPlayerView.swift
//  DGPlayer
//
//  Created by dd on 2018/12/6.
//  Copyright © 2018年 dd. All rights reserved.
//

import UIKit
import AVFoundation

class DGPlayerView: UIView {

    var leftConstraint: CGFloat = 0
    var topConstraint: CGFloat = 0
    var widthConstraint: CGFloat = 0
    var heightConstraint: CGFloat = 0
    
    
    
    private lazy var cover: UIButton = {
        let cover = UIButton()
        cover.backgroundColor = UIColor.black
        cover.alpha = 0.7
        return cover
    }()
    
    private lazy var messageLabel: UILabel = { [unowned self] in
        let messageLabel = UILabel()
        messageLabel.font = UIFont.systemFont(ofSize: 13)
        messageLabel.textColor = UIColor.white
        messageLabel.textAlignment = .center
        return messageLabel
    }()
    
    private lazy var eplisodeCover: UIButton = {
        let eplisodeCover = UIButton()
        eplisodeCover.backgroundColor = UIColor.black
        eplisodeCover.alpha = 0.8
        
        return eplisodeCover
    }()
    
    private var replayBtn: UIButton?
    
    private lazy var brightnessAndVolumeView:DGBrightnessAndVolumeView = DGBrightnessAndVolumeView.shareSingle
    private lazy var previewView: DGPreviewView = DGPreviewView.shareSingle
    
    private lazy var waitingView: DGLoadingView = {
        let waittingView = DGLoadingView()
        waittingView.isHidesWhenStopped = true
        return waittingView
    }()
    
    
    private var imageGenerator: AVAssetImageGenerator?
    private var asset: AVURLAsset?
    private var playerItem: AVPlayerItem?
    private lazy var playerLayer: AVPlayerLayer = AVPlayerLayer(player: player)
    private lazy var player: AVPlayer = AVPlayer()
    
    private lazy var tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(showOrHideControlPanel))
   
    private var timeObserver: Any?
    
    private var isControlPanelShow = true
    private var isLandscape = false
    @objc  var thumbImages:NSMutableArray =  NSMutableArray()
 
    
    private var currentTime: TimeInterval = 0{
        didSet{
            currentTimeLabel.text = String(format: "%02ld:%02ld", Int(currentTime)/60,Int(currentTime)%60)
        }
    }
    
    private var totalTime: TimeInterval = 0 {
        didSet{
            totalTimeLabel.text = String(format: "%02ld:%02ld", Int(totalTime)/60,Int(totalTime)%60)
        }
    }
    
    @IBOutlet private weak var bottomView: UIView!
    @IBOutlet private weak var progressSlider: UISlider!
    @IBOutlet private weak var loadedView: UIProgressView!
    @IBOutlet private weak var playBtn: UIButton!
    @IBOutlet private weak var currentTimeLabel: UILabel!
    @IBOutlet private weak var totalTimeLabel: UILabel!
    @IBOutlet private weak var episodeBtn: UIButton!
    @IBOutlet private weak var rotateBtn: UIButton!
    @IBOutlet weak var rotateBtnLeadingConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        layer.addSublayer(playerLayer)
        setupUI()
        addGesture()
        showOrHideControlPanel()
        setupBrightnessAndVolumeView()
        addObserver(self, forKeyPath: "thumbImages", options: .new, context: nil)
    }
    
    deinit {
        removePlayItemObserverAndNotification()
        removeTimeObserver()
        self.removeObserver(self, forKeyPath: "thumbImages")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer.frame = self.bounds
        brightnessAndVolumeView.frame = self.bounds
        
        cover.frame = self.bounds
        
        let previewViewWH: CGFloat = 180
        let previewViewX = (self.bounds.width - previewViewWH) * 0.5
        let previewViewY = (self.bounds.height - previewViewWH) * 0.5
        previewView.frame = CGRect(x: previewViewX, y: previewViewY, width: previewViewWH, height: previewViewWH)
        
        let waitingViewWH: CGFloat = 80
        let waitingViewX = (self.bounds.width - waitingViewWH) * 0.5
        let waitingViewY = (self.bounds.height - waitingViewWH) * 0.5
        waitingView.frame = CGRect(x: waitingViewX, y: waitingViewY, width: waitingViewWH, height: waitingViewWH)
        
        let messageLebalX: CGFloat = 0
        let messageLabelY: CGFloat = bounds.height / 2 - 15
        let messageLabelW = bounds.width
        let messageLabelH: CGFloat = 30
        messageLabel.frame = CGRect(x: messageLebalX, y: messageLabelY, width: messageLabelW, height: messageLabelH)
        
        bringSubviewToFront(brightnessAndVolumeView)
        bringSubviewToFront(bottomView)
        bringSubviewToFront(waitingView)
        bringSubviewToFront(previewView)
        bringSubviewToFront(cover)
    }
    
    // 拖拽进度条
    @IBAction func drapProgressAction(_ sender: UISlider) {
        // 把播放器控制面板显示属性设置为false 避免拖动时触发手势隐藏面板
        isControlPanelShow = false
        showOrHideControlPanel()
        
        self.currentTime = TimeInterval(sender.value)
        
        player.pause()
        removeTimeObserver()
        previewView.alpha = 1
        previewView.time = TimeInterval(sender.value)
        previewView.progressView.setProgress((sender.value / Float(totalTime)), animated: true)
        
        let imageIndex = Int(sender.value / 10)
        if imageIndex < thumbImages.count{
            previewView.image = thumbImages[imageIndex] as? UIImage
            if sender.value == Float(totalTime){
                previewView.image = thumbImages.lastObject as? UIImage
            }
        }else{
            previewView.image = nil
        }
    }
    
    @IBAction func playOrPauseAction(_ sender: UIButton) {
        playOrPause()
    }
    
    @IBAction func rotateScreen(_ sender: UIButton) {
        isControlPanelShow = false
        showOrHideControlPanel()
        
        if isLandscape{// 转至竖屏
            setForceDeviceOrientation(deviceOrientation: .portrait)
        }else{
            setForceDeviceOrientation(deviceOrientation: .landscapeLeft)
            UIApplication.shared.statusBarStyle = .lightContent
        }
    }
    
    // 进度条拖拽结束
    @objc private func progressDragEnd(sender: UISlider){
        // 把播放器控制面板显示属性设置为NO 避免拖动时触发手势隐藏面板
        isControlPanelShow = false
        UIView.animate(withDuration: 0.5) {
            self.previewView.alpha = 0
        }
        
        player.seek(to: CMTimeMake(value: Int64(progressSlider.value), timescale: 1), toleranceBefore: CMTime.zero, toleranceAfter: CMTime.zero)
        addTimerObserver()
        player.play()
        // 延迟10.0秒后隐藏播放控制面板
        perform(#selector(autoFadeOutControlPanelAndStatusBar), with: nil, afterDelay: 10)
    }
    
    // 自动淡出播放控制面板
    @objc private func autoFadeOutControlPanelAndStatusBar(){
        NSObject.cancelPreviousPerformRequests(withTarget: self)
        hideControlPanel()
        if isLandscape {return}
        hideStatusBar()
    }
    
    private func playOrPause(){
        if isPlaying() {
            playBtn.isSelected = true
            player.pause()
        }else{
            playBtn.isSelected = false
            player.play()
        }
    }
    
    private func isPlaying() -> Bool{
        let status = self.player.timeControlStatus
        switch status {
        case .playing:
            return true
        case .paused:
            return false
        case .waitingToPlayAtSpecifiedRate:
            return false
        }
    }
}

extension DGPlayerView{
    
    private func setupUI(){
        addSubview(previewView)
        playBtn.setImage(UIImage(named: "Play"), for: .selected)
        
        progressSlider.setThumbImage(UIImage(named: "icmpv_thumb_light"), for: .normal)
        progressSlider.value = 0
        loadedView.progress = 0
        currentTimeLabel.text = "00:00"
        totalTimeLabel.text = "00:00"
        progressSlider.addTarget(self, action: #selector(progressDragEnd(sender:)), for: [.touchUpInside,.touchCancel])
        addSubview(waitingView)
    }
    
    
    // 亮度和音量调节View
    private func setupBrightnessAndVolumeView(){
        brightnessAndVolumeView.progressChangeHandle = {[unowned self] (delta) in
            self.gestureDragProgress(delta: delta)
        }
        brightnessAndVolumeView.progressPortraitEnd = {[unowned self] in
            self.gestureDragEnd()
        }
        brightnessAndVolumeView.progressLandscapeEnd = {[unowned self] in
            self.progressDragEnd(sender: self.progressSlider)
        }
        addSubview(brightnessAndVolumeView)
    }
    
    // 横向手势拖拽时显示进度条或者缩略图
    private func gestureDragProgress(delta:CGFloat){
        isControlPanelShow = false
        var currentTime = CMTimeGetSeconds(player.currentTime())
        currentTime = currentTime + Double(delta)
        progressSlider.value = Float(currentTime)
        drapProgressAction(progressSlider)
    }
    
    // // 横向手势拖拽手势结束
    private func gestureDragEnd(){
        UIView.animate(withDuration: 0.5) {
            self.previewView.alpha = 0
        }
    }
    
    private func addGesture(){
        addGestureRecognizer(tapGesture)
    }
    
    @objc private func showOrHideControlPanel(){
        if isControlPanelShow {
            hideControlPanel()
            if isLandscape{
                hideStatusBar()
            }
        }else{
            NSObject.cancelPreviousPerformRequests(withTarget: self)
            UIView.animate(withDuration: 0.5) {
                self.showControlPanel()
                self.showStatusBar()
            }
            
            perform(#selector(autoFadeOutControlPanelAndStatusBar), with: nil, afterDelay: 10)
        }
    }
    
    // 显示播放控制面板
    private func showControlPanel(){
        isControlPanelShow = true
        bottomView.alpha = 1
    }
    
    // 隐藏播放控制面板
    private func hideControlPanel(){
        isControlPanelShow = false
        bottomView.alpha = 0
    }
    
    // 重置播放器
    private func resetPlayer(){
        player.pause()
        removePlayItemObserverAndNotification()
        removeTimeObserver()
        player.currentItem?.cancelPendingSeeks()
        player.currentItem?.asset.cancelLoading()
        imageGenerator = nil
        player.rate = 0
        totalTime = 0
        progressSlider.value = 0
        drapProgressAction(progressSlider)
        player.replaceCurrentItem(with: nil)
        messageLabel.removeFromSuperview()
    }
    
    // 给进度条Slider添加时间OB
    private func addTimerObserver(){
        timeObserver = player.addPeriodicTimeObserver(forInterval: CMTimeMake(value: 1, timescale: 1), queue: DispatchQueue.main) {[unowned self] (time) in
            
            self.currentTime = CMTimeGetSeconds(self.player.currentTime())
            self.progressSlider.value = Float(CMTimeGetSeconds(self.player.currentTime()))
        }
    }
    
    // 给playItem添加观察者KVO
    private func addPlayItemObserverAndNotification(){
        playerItem?.addObserver(self, forKeyPath: "status", options: .new, context: nil)
        playerItem?.addObserver(self, forKeyPath: "loadedTimeRanges", options: .new, context: nil)
        playerItem?.addObserver(self, forKeyPath: "playbackBufferEmpty", options: .new, context: nil)
        playerItem?.addObserver(self, forKeyPath: "playbackLikelyToKeepUp", options: .new, context: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(playFinished(note:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(changeStatusBarStyle(note:)), name: UIApplication.didChangeStatusBarOrientationNotification, object: nil)
    }
    
    // 移除观察者和通知
    private func removePlayItemObserverAndNotification(){
        playerItem?.removeObserver(self, forKeyPath: "status")
        playerItem?.removeObserver(self, forKeyPath: "loadedTimeRanges")
        playerItem?.removeObserver(self, forKeyPath: "playbackBufferEmpty")
        playerItem?.removeObserver(self, forKeyPath: "playbackLikelyToKeepUp")
        NotificationCenter.default.removeObserver(self)
    }
    
    // 移除时间OB
    private func removeTimeObserver(){
        if timeObserver != nil {
            player.removeTimeObserver(timeObserver!)
            timeObserver = nil
        }
    }
    
    // KVO监测到播放完调用
    @objc private func playFinished(note: Notification){
        addSubview(cover)
        playerItem = note.object as? AVPlayerItem
        removeGestureRecognizer(tapGesture)
    }
    
   
    
    //// KVO检测播放器各种状态
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard let playItem = object as? AVPlayerItem else{return}
        if keyPath == "status"{ // 检测播放器状态
            let status = change![NSKeyValueChangeKey.newKey] as! Int
            if status == AVPlayer.Status.readyToPlay.rawValue{
                progressSlider.maximumValue = Float(totalTime)
                playOrPause()
            }else if status == AVPlayer.Status.failed.rawValue{
                waitingView.stopAnimating()
                messageLabel.text = "资源不存在..."
                addSubview(messageLabel)
            } else if status == AVPlayer.Status.unknown.rawValue{
                waitingView.stopAnimating()
                messageLabel.text = "网络错误，请检查手机网络..."
                addSubview(messageLabel)
            }
            
            progressSlider.maximumValue = Float(totalTime)
            playOrPause()
        }else if keyPath == "loadedTimeRanges"{ // 检测缓存状态
            let loadedTimeRanges = playItem.loadedTimeRanges
            let timeRange = loadedTimeRanges.first!.timeRangeValue
            let bufferingTime = CMTimeGetSeconds(timeRange.start) + CMTimeGetSeconds(timeRange.duration)
            loadedView.setProgress(Float(bufferingTime / totalTime), animated: true)
            if bufferingTime >= CMTimeGetSeconds(playItem.currentTime()) + 5{
                waitingView.stopAnimating()
            }
        } else if keyPath == "playbackBufferEmpty"{// 缓存为空
            if playItem.isPlaybackBufferEmpty{
                waitingView.startAnimating()
            }
        } else if keyPath == "playbackLikelyToKeepUp"{ // 缓存足够能播放
            if playItem.isPlaybackLikelyToKeepUp{
                waitingView.stopAnimating()
            }
        } else if keyPath == "thumbImages"{
            DispatchQueue.main.async(execute: {
                let imageIndex = Int(self.progressSlider.value) / 10
                if imageIndex < self.thumbImages.count {
                    self.previewView.image = self.thumbImages[imageIndex] as? UIImage
                }
            })
        }
    }
    // 获取AVURLAsset的任意一帧图片
    private func thumbImageForVideo(videoURL: URL, time: TimeInterval) -> UIImage?{
        imageGenerator?.cancelAllCGImageGeneration()
        imageGenerator?.appliesPreferredTrackTransform = true
        imageGenerator?.maximumSize = CGSize(width: 160, height: 90)
        var thumbImageRef: CGImage? = nil
        do{
            thumbImageRef = try imageGenerator!.copyCGImage(at: CMTime(seconds: time, preferredTimescale: 1), actualTime: nil)
        }catch{
            print(error)
        }
        if thumbImageRef != nil {
            let thumbImage = UIImage(cgImage: thumbImageRef!)
             return thumbImage
        }else{
            return nil
        }
    }
}

extension DGPlayerView{
    // 显示状态栏
    private func showStatusBar(){
        UIApplication.shared.isStatusBarHidden = false
    }
    
    // 隐藏状态栏
    private func hideStatusBar(){
        UIApplication.shared.isStatusBarHidden = true
    }
    
    @objc private func changeStatusBarStyle(note: Notification){
        let statusOrientation = note.userInfo!["UIApplicationStatusBarOrientationUserInfoKey"] as! Int
        if statusOrientation == UIInterfaceOrientation.portrait.rawValue{
            UIApplication.shared.statusBarStyle = .lightContent
        } else {
            UIApplication.shared.statusBarStyle = .default
        }
    }
    
    // 横竖屏适配
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if self.traitCollection.verticalSizeClass == .regular{
            // 转至竖屏
            
        }
    }
    
    // 强制切换屏幕方向
    private func setForceDeviceOrientation(deviceOrientation: UIInterfaceOrientation){
        ///swift移除了NSInvocation 暂时找不到强制旋转方法,只能桥接
        DeviceTool.interfaceOrientation(deviceOrientation)
    }
}

extension DGPlayerView{
    func playWithPlayInfo(playInfo: DGPlayInfo){
        thumbImages.removeAllObjects()
        // 重置player
        resetPlayer()
        showOrHideControlPanel()
        previewView.alpha = 0
        
        let url = URL(string: playInfo.url)!
        asset = AVURLAsset(url: url)
        playerItem = AVPlayerItem(asset: asset!)
        imageGenerator = AVAssetImageGenerator(asset: asset!)
        
        waitingView.startAnimating()
        self.totalTime = CMTimeGetSeconds(self.asset!.duration)
        let group = DispatchGroup()
        let queue = DispatchQueue(label: "dgQroup")
        queue.async(group: group, qos: .default, flags: []) {
            self.totalTime = CMTimeGetSeconds(self.asset!.duration)
        }
        queue.async(group: group, qos: .default, flags: []) {
            let captureTime = self.totalTime / 10
            for index in 0...Int(captureTime - 1){
                let image = self.thumbImageForVideo(videoURL: url, time: TimeInterval(10 * index))
                if image != nil{
                    self.mutableArrayValue(forKey: "thumbImages").add(image!)
                }
            }
        }
        
        group.notify(queue: queue) {
            let lastImage = self.thumbImageForVideo(videoURL: url, time: self.totalTime)
            if lastImage != nil{
                self.mutableArrayValue(forKey: "thumbImages").add(lastImage!)
            }
        }
        
        player.replaceCurrentItem(with: playerItem)
        
        addTimerObserver()
        addPlayItemObserverAndNotification()
    }
    
    class func loadFromNib() -> DGPlayerView{
        return Bundle.main.loadNibNamed("DGPlayerView", owner: nil, options: nil)!.last! as! DGPlayerView
    }
    
}
