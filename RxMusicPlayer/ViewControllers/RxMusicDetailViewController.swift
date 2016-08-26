//
//  RxMusicDetailViewController.swift
//  RxMusicPlayer
//
//  Created by Nguyễn Tiến Đạt on 8/25/16.
//  Copyright © 2016 Nguyễn Tiến Đạt. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import DOUAudioStreamer
import SDWebImage

class RxMusicDetailViewController: RxBaseViewController {

    static var vc: RxMusicDetailViewController!
    static var token: dispatch_once_t = 0

    // Single ton
    static func sharedInstance() -> RxMusicDetailViewController {
        dispatch_once(&token) {
            print("Create new VC")
            vc = UIStoryboard.init(name: "Music", bundle: NSBundle.mainBundle()).instantiateViewControllerWithIdentifier("RxMusicDetailViewController") as! RxMusicDetailViewController
            vc.streamer = DOUAudioStreamer()
        }
        print("Reusing VC")
        return vc
    }

    // IBOutlets
    @IBOutlet weak var hideButton: UIButton!

    @IBOutlet weak var musicSlider: UISlider!

    @IBOutlet weak var backgroudImageView: UIImageView!
    @IBOutlet weak var albumImageView: UIImageView!

    @IBOutlet weak var backgroudView: UIView!

    @IBOutlet weak var musicNameLabel: UILabel!
    @IBOutlet weak var singerLabel: UILabel!
    @IBOutlet weak var musicTitleLabel: UILabel!
    @IBOutlet weak var beginTimeLabel: UILabel!
    @IBOutlet weak var endTimeLabel: UILabel!

    @IBOutlet weak var musicMenuButton: UIButton!
    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var nextMusicButton: UIButton!
    @IBOutlet weak var musicCycleButton: UIButton!
    @IBOutlet weak var musicToggleButton: UIButton!
    @IBOutlet weak var previousMusicButton: UIButton!

    // Variables
    weak var items: Variable<[RxMusic]>?

    var musicDurationTimer: NSTimer?
    var streamer: DOUAudioStreamer!
    var currentMusic: RxMusic!
    var visualEffectView: UIVisualEffectView!

    var isPlaying = false
    var currentIndex = 0
    var specialIndex = 0

    var kStatusContext: UInt8 = 1
    var kDurationContext: UInt8 = 1
    var kBufferingRatioContext: UInt8 = 1
    // Constants
    let musicIndicator = RxMusicIndicator.shareInstance

    // Life cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        initVariable()
        initRx()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        createStream()
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)

        streamer.removeObserver(self, forKeyPath: "status")
        streamer.removeObserver(self, forKeyPath: "duration")
        streamer.removeObserver(self, forKeyPath: "bufferingRatio")
    }

    // Music Functions
    private func createStream() {
        // init index
        if (specialIndex > 0) {
            currentIndex = specialIndex
            specialIndex = 0
        }

        // init stream
        guard let currentMusic = items?.value[currentIndex] else { return }
        self.currentMusic = currentMusic

        setupMusicWithCurrentMusic()
        // loadPreviousAndNextMusicImage()

        // init track
        guard let soundFilePath = NSBundle.mainBundle().pathForResource(currentMusic.fileName, ofType: "mp3") else { return }
        let fileURL = NSURL(fileURLWithPath: soundFilePath)

        let track = RxTrack()
        track.url = fileURL

        removeStreamerObserver()

        streamer = nil
        streamer = DOUAudioStreamer(audioFile: track)

        addStreamerObserver()
        streamer.play()
    }

    private func removeStreamerObserver() {
        // Waiting for another try catch solution
//        streamer.removeObserver(self, forKeyPath: "status")
//        streamer.removeObserver(self, forKeyPath: "duration")
//        streamer.removeObserver(self, forKeyPath: "bufferingRatio")
    }

    private func addStreamerObserver() {
        streamer.addObserver(self, forKeyPath: "status", options: NSKeyValueObservingOptions.New, context: &kStatusContext)
        streamer.addObserver(self, forKeyPath: "duration", options: NSKeyValueObservingOptions.New, context: &kDurationContext)
        streamer.addObserver(self, forKeyPath: "bufferingRatio", options: NSKeyValueObservingOptions.New, context: &kBufferingRatioContext)
    }

    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String: AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if context == &kStatusContext {
            dispatch_after(0, dispatch_get_main_queue()) { () -> Void in
                self.updateStatus()
            }
        } else if context == &kDurationContext {
            dispatch_after(0, dispatch_get_main_queue()) { () -> Void in
                self.timerAction()
            }
        } else if context == &kBufferingRatioContext {
            dispatch_after(0, dispatch_get_main_queue()) { () -> Void in
                self.updateBufferingStatus()
            }
        } else {
            super.observeValueForKeyPath(keyPath, ofObject: object, change: change, context: context)
        }
    }

    private func updateStatus() {
        isPlaying = false
        musicIndicator.state = .Stopped
        switch streamer.status {
        case .Playing:
            isPlaying = true
            musicIndicator.state = .Playing
            break

        case .Paused:
            break

        case .Idle:
            break

        case .Finished:
//            if (_musicCycleType == MusicCycleTypeLoopSingle) {
//                [_streamer play];
//            } else {
//                [self playNextMusic: nil]
//
            break

        case .Buffering:
            musicIndicator.state = .Playing
            break

        case .Error:
            break
        }
        updateMusicsCellsState()
    }

    private func timerAction() {

    }

    private func updateBufferingStatus() {

    }

    private func updateMusicsCellsState() {

    }

    private func setupMusicWithCurrentMusic() {
        musicTitleLabel.text = currentMusic.name
        singerLabel.text = currentMusic.artistName
//        musicTitleLabel

        setupBackground()
    }

    private func setupBackground() {
        albumImageView.layer.cornerRadius = 7
        albumImageView.layer.masksToBounds = true

        // download image
        let width = Int((Screen.WIDTH - 70) * 2)
        let url = NSURL.qiniuImageCenter(currentMusic.cover, width, 0)

        let imagePlaceHolder = UIImage(named: "music_placeholder")
        albumImageView
            .sd_setImageWithURL(url, placeholderImage: imagePlaceHolder, options: [.RefreshCached, .RetryFailed])

        backgroudImageView
            .sd_setImageWithURL(url, placeholderImage: imagePlaceHolder, options: [.RefreshCached, .RetryFailed])

        // marking blur
        if visualEffectView == nil {
            let blurEffect = UIBlurEffect(style: .Light)
            visualEffectView = UIVisualEffectView(effect: blurEffect)
            visualEffectView.frame = view.bounds

            backgroudView.addSubview(visualEffectView)
            backgroudView.addSubview(visualEffectView)
        }

        backgroudImageView.startAnimating()
        albumImageView.startAnimating()
    }

    private func checkMusicFavoritedIcon() {
        if currentMusic.isFavorited {
            favoriteButton.setImage(UIImage(named: "red_heart"), forState: .Normal)
        } else {
            favoriteButton.setImage(UIImage(named: "empty_heart"), forState: .Normal)
        }
    }
    // Functions
    private func initVariable() {
        musicDurationTimer = NSTimer.scheduledTimerWithTimeInterval(0.4, target: self, selector: #selector(updateSliderValue), userInfo: nil, repeats: true)

    }

    private func invalidateDurationTimer() {
        if musicDurationTimer != nil && musicDurationTimer!.valid {
            musicDurationTimer?.invalidate()
        }
        musicDurationTimer = nil
    }

    @objc private func updateSliderValue() {
        if streamer == nil { return }
        if streamer.status == .Finished { streamer.play() }
        if streamer.duration == 0 {
            musicSlider.setValue(0, animated: false)
        } else {
            if (streamer.currentTime >= streamer.duration) {
                streamer.currentTime -= streamer.duration
            }
            let progress = Float(streamer.currentTime / streamer.duration)
            musicSlider.setValue(progress, animated: true)
            updateProgressLabelValue()
        }
    }

    private func updateProgressLabelValue() {
        beginTimeLabel.text = String.timeIntervalToMMSSFormat(streamer.currentTime)
        endTimeLabel.text = String.timeIntervalToMMSSFormat(streamer.duration)
    }

    private func favoriteMusic() {
        currentMusic.isFavorited = true
        favoriteButton.setImage(UIImage(named: "red_heart"), forState: .Normal)
    }

    private func unfavoriteMusic() {
        currentMusic.isFavorited = false
        favoriteButton.setImage(UIImage(named: "empty_heart"), forState: .Normal)
    }

    private func initRx() {
        hideButton
            .rx_tap
            .subscribeNext {
                self.dismissViewControllerAnimated(true, completion: nil) }
            .addDisposableTo(disposeBag)

        musicToggleButton
            .rx_tap
            .subscribeNext {
                self.isPlaying ? self.streamer.pause() : self.streamer.play() }
            .addDisposableTo(disposeBag)

        favoriteButton
            .rx_tap
            .subscribeNext {
                // do animation
                self.favoriteButton.startDuangAnimation()
                if self.currentMusic.isFavorited { self.unfavoriteMusic() }
                else { self.favoriteMusic() } }
            .addDisposableTo(disposeBag)

    }
}
