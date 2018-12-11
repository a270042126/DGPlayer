//
//  DGPlayView.swift
//  DGPlayer
//
//  Created by dd on 2018/12/8.
//  Copyright © 2018年 dd. All rights reserved.
//

import UIKit
import AVFoundation
import SnapKit



protocol DGPlayerViewDelegate: class {
    func dgplayerViewRotateButtonClicked()
}

class DGPlayerView: UIView {
    
    weak var delegate:DGPlayerViewDelegate?
    
    //BottomView
    private lazy var playButton: UIButton = { [unowned self] in
        let button = UIButton()
        button.setImage(UIImage(named: "Play"), for: .selected)
        button.addTarget(self, action: #selector(playButtonClicked(sender:)), for: .touchUpInside)
        button.setImage(UIImage(named: "Stop"), for: .normal)
        return button
        }()
    
    private lazy var rotateButton: UIButton = { [unowned self] in
        let button = UIButton()
        button.addTarget(self, action: #selector(rotateButtonClicked), for: .touchUpInside)
        button.setImage(UIImage(named: "Rotation"), for: .normal)
        return button
        }()
    
    private lazy var loadedView: UIProgressView = {
        let progress = UIProgressView()
        progress.progressTintColor = UIColor(red: 167 / 255.0, green: 167 / 255.0, blue: 167 / 255.0, alpha: 1)
        progress.progress = 0
        return progress
    }()
    
    private lazy var progressSlider: UISlider = { [unowned self] in
        let slider = UISlider()
        slider.minimumValue = 0
        slider.maximumValue = 0
        slider.minimumTrackTintColor = UIColor.red
        slider.maximumTrackTintColor = UIColor.clear
        slider.addTarget(self, action: #selector(progressValueChanged(sender:)), for: .valueChanged)
        slider.addTarget(self, action: #selector(progressDragEnd(sender:)), for: [.touchUpInside,.touchCancel,.touchUpOutside])
        slider.setThumbImage(UIImage(named: "icmpv_thumb_light"), for: .normal)
        return slider
        }()
    
    private lazy var distinctButton: UIButton = { [unowned self] in
        let button = UIButton()
        button.setTitle("高清", for: .normal)
        button.addTarget(self, action: #selector(distinctButtonClicked(sender:)), for: .touchUpInside)
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
    
    private lazy var bottomView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.clear
        return view
    }()
    
    private lazy var waitingView: DGLoadingView = {
        let waittingView = DGLoadingView()
        waittingView.isHidesWhenStopped = true
        return waittingView
    }()
    
    private lazy var cover: UIButton = {
        let cover = UIButton()
        cover.backgroundColor = UIColor.black
        cover.alpha = 0.7
        return cover
    }()
    
    private lazy var messageLabel: UILabel = {
        let messageLabel = UILabel()
        messageLabel.font = UIFont.systemFont(ofSize: 13)
        messageLabel.textColor = UIColor.white
        messageLabel.textAlignment = .center
        return messageLabel
    }()
    
    private lazy var replayButton: UIButton = { [unowned self] in
        let button = UIButton(type: UIButton.ButtonType.custom)
        button.setImage(UIImage(named: "replay"), for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        button.contentHorizontalAlignment = .fill
        button.contentVerticalAlignment = .fill
        button.addTarget(self, action: #selector(replayButtonClicked), for: .touchUpInside)
        cover.addSubview(button)
        return button
    }()
   
    private lazy var playerLayer: AVPlayerLayer = AVPlayerLayer(player: player)
    private lazy var player: AVPlayer = AVPlayer()
    private var asset: AVURLAsset?
    private var playerItem: AVPlayerItem?
    private var timeObserver: Any?
    private lazy var tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(showOrHideControlPanel))
    
    private var currentTime: TimeInterval = 0{
        didSet{
            currentTimeLabel.text = String(format: "%02ld:%02ld", Int(currentTime)/60,Int(currentTime)%60)
            progressSlider.value = Float(currentTime)
        }
    }
    
    private var totalTime: TimeInterval = 0{
        didSet{
            totalTimeLabel.text = String(format: "%02ld:%02ld", Int(totalTime)/60,Int(totalTime)%60)
            progressSlider.maximumValue = Float(totalTime)
        }
    }
    
    private var isControlPanelShow = false {
        didSet{
            if !isControlPanelShow {
                bottomView.alpha = 0
                
            }else{
                NSObject.cancelPreviousPerformRequests(withTarget: self)
                UIView.animate(withDuration: 0.5) {
                    self.bottomView.alpha = 1
                }
                perform(#selector(autoFadeOutControlPanelAndStatusBar), with: nil, afterDelay: 10)
            }
        }
    }
    
    private var isFullScreen = false
    private var parentView: UIView?
    private var viewFrame: CGRect = CGRect()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCenterUI()
        setupBottomViewUI()
        addGestureRecognizer(tapGesture)
        player.addObserver(self, forKeyPath: "rate", options: .new, context: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupCenterUI(){
        self.backgroundColor = UIColor.black
        layer.addSublayer(playerLayer)
        addSubview(waitingView)
        
        waitingView.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer.frame = bounds
        messageLabel.center.x = bounds.width * 0.5
        messageLabel.center.y = bounds.height * 0.5
        cover.frame = bounds
        replayButton.frame.size = CGSize(width: 50, height: 50)
        replayButton.center.x = bounds.width * 0.5
        replayButton.center.y = bounds.height * 0.5
        updateBottonViewUI()
    }
    
    override func didMoveToWindow() {
        super.didMoveToWindow()
         NSObject.cancelPreviousPerformRequests(withTarget: self)
    }
    
    deinit {
        removePlayItemObserverAndNotification()
        removeTimeObserver()
        player.removeObserver(self, forKeyPath: "rate")
        print("deint1")
    }
}

//MARK:--BottomView
extension DGPlayerView {
    
    private func setupBottomViewUI(){
        addSubview(bottomView)
        bottomView.addSubview(backgroundImageView)
        bottomView.addSubview(playButton)
        bottomView.addSubview(currentTimeLabel)
        bottomView.addSubview(rotateButton)
        bottomView.addSubview(distinctButton)
        bottomView.addSubview(totalTimeLabel)
        bottomView.addSubview(loadedView)
        bottomView.addSubview(progressSlider)
        
        bottomView.snp.makeConstraints { (make) in
            make.height.equalTo(40)
            make.bottom.left.right.equalToSuperview()
        }
        
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
            make.right.equalTo(totalTimeLabel.snp.left).offset(-8)
            make.centerY.equalToSuperview().offset(-1)
        }
        
        loadedView.snp.makeConstraints { (make) in
            make.height.equalTo(2)
            make.left.equalTo(currentTimeLabel.snp.right).offset(8)
            make.right.equalTo(totalTimeLabel.snp.left).offset(-8)
            make.centerY.equalToSuperview()
        }
        
        backgroundImageView.snp.makeConstraints { (make) in
            make.top.left.right.bottom.equalToSuperview()
        }
        
    }
    
    private func updateBottonViewUI(){
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
    }
}


extension DGPlayerView {
    
    // 重置播放器
    private func resetPlayer(){
        player.pause()
        removePlayItemObserverAndNotification()
        removeTimeObserver()
        player.currentItem?.cancelPendingSeeks()
        player.currentItem?.asset.cancelLoading()
        player.rate = 0
        totalTime = 0
        currentTime = 0
        player.replaceCurrentItem(with: nil)
        messageLabel.removeFromSuperview()
        cover.removeFromSuperview()
    }
    
    private func playOrPause(){
        if isPlaying() {
            playButton.isSelected = true
            player.pause()
        }else{
             playButton.isSelected = false
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
    
    // 给进度条Slider添加时间OB
    private func addTimerObserver(){
        timeObserver = player.addPeriodicTimeObserver(forInterval: CMTimeMake(value: 1, timescale: 1), queue: DispatchQueue.main) {[unowned self] (time) in
            self.currentTime = CMTimeGetSeconds(self.player.currentTime())
        }
    }
    
    // 移除时间OB
    private func removeTimeObserver(){
        if timeObserver != nil {
            player.removeTimeObserver(timeObserver!)
            timeObserver = nil
        }
    }
    
    // 给playItem添加观察者KVO
    private func addPlayItemObserverAndNotification(){
        playerItem?.addObserver(self, forKeyPath: "status", options: .new, context: nil)
        playerItem?.addObserver(self, forKeyPath: "loadedTimeRanges", options: .new, context: nil)
        playerItem?.addObserver(self, forKeyPath: "playbackBufferEmpty", options: .new, context: nil)
        playerItem?.addObserver(self, forKeyPath: "playbackLikelyToKeepUp", options: .new, context: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(playFinished(note:)), name: Notification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
    }
    
    // 移除观察者和通知
    private func removePlayItemObserverAndNotification(){
        playerItem?.removeObserver(self, forKeyPath: "status")
        playerItem?.removeObserver(self, forKeyPath: "loadedTimeRanges")
        playerItem?.removeObserver(self, forKeyPath: "playbackBufferEmpty")
        playerItem?.removeObserver(self, forKeyPath: "playbackLikelyToKeepUp")
        NotificationCenter.default.removeObserver(self)
    }
    
    /// KVO检测播放器各种状态
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard let playItem = object as? AVPlayerItem else{return}
        if keyPath == "status"{ // 检测播放器状态
            let status = change![NSKeyValueChangeKey.newKey] as! Int
            if status == AVPlayer.Status.readyToPlay.rawValue{
                playOrPause()
            }else if status == AVPlayer.Status.failed.rawValue{
                waitingView.stopAnimating()
                messageLabel.text = "资源不存在..."
                addSubview(messageLabel)
            } else if status == AVPlayer.Status.unknown.rawValue{
                waitingView.stopAnimating()
                messageLabel.text = "网络错误，请检查手机网络..."
                addSubview(messageLabel)
            }else{
                playOrPause()
            }
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
        } else if keyPath == "rate"{
            let rate = change![.newKey] as! Int
            if rate == 0{
                isControlPanelShow = false
                playButton.isSelected = true
            } else {
                playButton.isSelected = false
            }
        }
    }
}


extension DGPlayerView{
    
    // KVO监测到播放完调用
    @objc private func playFinished(note: Notification){
        addSubview(cover)
        playerItem = note.object as? AVPlayerItem
        removeGestureRecognizer(tapGesture)
    }
    
    // 自动淡出播放控制面板
    @objc private func autoFadeOutControlPanelAndStatusBar(){
        NSObject.cancelPreviousPerformRequests(withTarget: self)
        isControlPanelShow = false
    }
    
    @objc private func showOrHideControlPanel(){
        isControlPanelShow = !isControlPanelShow
    }
    
    @objc private func playButtonClicked(sender: UIButton){
        playOrPause()
    }
    
    @objc private func progressDragEnd(sender: UISlider){
        self.currentTime = TimeInterval(sender.value)
        player.seek(to: CMTimeMake(value: Int64(progressSlider.value), timescale: 1), toleranceBefore: CMTime.zero, toleranceAfter: CMTime.zero)
        addTimerObserver()
        player.play()
        // 延迟10.0秒后隐藏播放控制面板
        
        perform(#selector(autoFadeOutControlPanelAndStatusBar), with: nil, afterDelay: 10)
    }
    
    @objc private func progressValueChanged(sender: UISlider){
        isControlPanelShow = true
        NSObject.cancelPreviousPerformRequests(withTarget: self)
        player.pause()
        removeTimeObserver()
    }
    
    //重播
    @objc private func replayButtonClicked(){
        cover.removeFromSuperview()
        isControlPanelShow = false
        playerItem?.seek(to: .zero, completionHandler: nil)
        player.play()
        addGestureRecognizer(tapGesture)
    }
    
    
    //旋转屏幕
    @objc private func rotateButtonClicked(){
//        if !isFullScreen{
//            onDeviceOrientation(.landscapeRight)
//            setDeviceOrientation(.landscapeRight)
//        }else{
//            onDeviceOrientation(.portrait)
//            setDeviceOrientation(.portrait)
//        }
        delegate?.dgplayerViewRotateButtonClicked()
    }
    
    @objc private func distinctButtonClicked(sender: UIButton){
        
    }
}


extension DGPlayerView{
    
    
    func setupPlay(urlStr:String){
        guard let url = URL(string: urlStr) else {
            return
        }
        
        resetPlayer()
        isControlPanelShow = false
        asset = AVURLAsset(url: url)
        playerItem = AVPlayerItem(asset: asset!)
        waitingView.startAnimating()
        totalTime = CMTimeGetSeconds(self.asset!.duration)
        player.replaceCurrentItem(with: playerItem)
        
        addTimerObserver()
        addPlayItemObserverAndNotification()
    }
    
}

