//
//  DGPlayView.swift
//  DGPlayer
//
//  Created by dd on 2018/12/8.
//  Copyright © 2018年 dd. All rights reserved.
//

import UIKit
import AVFoundation

protocol DGPlayViewDelegate: class {
    func dgplayViewRotateButtonClicked()
}

class DGPlayView: UIView {
    
    weak var delegate:DGPlayViewDelegate?
    
    private lazy var bottomView: DGBottomView = { [unowned self] in
        let view = DGBottomView()
        view.alpha = 0
        view.playButton.addTarget(self, action: #selector(playButtonClicked(sender:)), for: .touchUpInside)
        view.rotateButton.addTarget(self, action: #selector(rotateButtonClicked), for: .touchUpInside)
        view.progressSlider.addTarget(self, action: #selector(progressValueChanged(sender:)), for: .valueChanged)
        view.progressSlider.addTarget(self, action: #selector(progressDragEnd(sender:)), for: [.touchUpInside,.touchCancel,.touchUpOutside])
        view.distinctButton.addTarget(self, action: #selector(distinctButtonClicked(sender:)), for: .touchUpInside)
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
    
    private lazy var messageLabel: UILabel = { [unowned self] in
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
    
    private var currentTime: TimeInterval = 0 {
        didSet{
            bottomView.currentTime = currentTime
        }
    }
    
    private var totalTime: TimeInterval = 0 {
        didSet{
            bottomView.totalTime = totalTime
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
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        addGestureRecognizer(tapGesture)
        player.addObserver(self, forKeyPath: "rate", options: .new, context: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI(){
        self.backgroundColor = UIColor.black
        layer.addSublayer(playerLayer)
        addSubview(bottomView)
        addSubview(waitingView)
        
        bottomView.snp.makeConstraints { (make) in
            make.height.equalTo(40)
            make.bottom.left.right.equalToSuperview()
        }
        
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

extension DGPlayView {
    
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
            bottomView.playButton.isSelected = true
            player.pause()
        }else{
             bottomView.playButton.isSelected = false
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
        NotificationCenter.default.addObserver(self, selector: #selector(playFinished(note:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
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
            bottomView.loadedView.setProgress(Float(bufferingTime / totalTime), animated: true)
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
                bottomView.playButton.isSelected = true
            } else {
                bottomView.playButton.isSelected = false
            }
        }
    }
}

extension DGPlayView{
    
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
        player.seek(to: CMTimeMake(value: Int64(bottomView.progressSlider.value), timescale: 1), toleranceBefore: CMTime.zero, toleranceAfter: CMTime.zero)
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
    
    @objc private func replayButtonClicked(){
        cover.removeFromSuperview()
        isControlPanelShow = false
        playerItem?.seek(to: .zero, completionHandler: nil)
        player.play()
        addGestureRecognizer(tapGesture)
    }
    
    @objc private func rotateButtonClicked(){
        delegate?.dgplayViewRotateButtonClicked()
    }
    
    @objc private func distinctButtonClicked(sender: UIButton){
        
    }
}

extension DGPlayView{
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
