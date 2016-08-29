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

enum MusicCycleType {
    case Shuffle
    case LoopSingle
    case LoopAll
    case Normal
}

class RxMusicDetailViewController: RxBaseViewController {

    static var vc: RxMusicDetailViewController!
    static var token: dispatch_once_t = 0

    // Singleton
    static func sharedInstance() -> RxMusicDetailViewController {
        dispatch_once(&token) {
            print("Create new VC")
            vc = UIStoryboard.init(name: "Music", bundle: NSBundle.mainBundle()).instantiateViewControllerWithIdentifier("RxMusicDetailViewController") as! RxMusicDetailViewController
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
    @IBOutlet weak var musicCycleButton: UIButton!

    @IBOutlet weak var previousMusicButton: UIButton!
    @IBOutlet weak var musicToggleButton: UIButton!
    @IBOutlet weak var nextMusicButton: UIButton!

    // Variables
    weak var items: Variable<[RxMusic]>?
    var currentMusic: RxMusic!

    var musicDurationTimer: NSTimer?
    var streamer: DOUAudioStreamer!
    var visualEffectView: UIVisualEffectView!

    var isPlaying = false

    var currentIndex = 0
    var specialIndex = 0

    var kStatusContext: UInt8 = 1
    var kDurationContext: UInt8 = 1
    var kBufferingRatioContext: UInt8 = 1

    let musicCycleType: MusicCycleType = .Normal

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

        removeStreamerObserver()
    }

    // Music Functions
    private func onSliderMusic(progress: Double) {
        if streamer == nil { return }
        if streamer.status == .Finished {
            streamer = nil
            createStream()
        }

        streamer.currentTime = streamer.duration * Double(progress)
        updateProgressLabelValue()
    }

    private func playPreviousMusic() {
        guard let musicCount = items?.value.count else {
            print("Oops..Something wrong")
            return
        }

        if musicCount == 1 {
            print("Just one song")
            return
        }

        if musicCycleType == .Shuffle && musicCount > 2 {
            // play shuffle
        } else {
            // play next song
            if currentIndex == 0 {
                currentIndex = musicCount - 1
            } else {
                currentIndex -= 1
            }
        }

        createStream()
    }

    private func playNextMusic() {
        guard let musicCount = items?.value.count else {
            print("Oops..Something wrong")
            return
        }

        if musicCount == 1 {
            print("Just one song")
            return
        }

        if musicCycleType == .Shuffle && musicCount > 2 {
            // play shuffle
        } else {
            // play next song
            if currentIndex == (musicCount - 1) {
                currentIndex = 0
            } else {
                currentIndex += 1
            }
        }

        createStream()
    }

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

        streamer = DOUAudioStreamer(audioFile: track)

        addStreamerObserver()
        streamer.play()
    }

    private func removeStreamerObserver() {
        if streamer != nil {
            streamer.removeObserver(self, forKeyPath: "status")
            streamer.removeObserver(self, forKeyPath: "duration")
            streamer.removeObserver(self, forKeyPath: "bufferingRatio")

            streamer = nil
        }
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

            musicToggleButton.startDuangAnimation()
            musicToggleButton.selected = false
            break

        case .Paused:
            musicToggleButton.startDuangAnimation()
            musicToggleButton.selected = true
            break

        case .Idle:
            break

        case .Finished:
            if musicCycleType == .LoopSingle {
                streamer.play()
            } else {
                playNextMusic()
            }
            break

        case .Buffering:
            musicIndicator.state = .Playing
            break

        case .Error:
            musicToggleButton.startDuangAnimation()
            musicToggleButton.selected = true
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

        nextMusicButton
            .rx_tap
            .subscribeNext (playNextMusic)
            .addDisposableTo(disposeBag)

        previousMusicButton
            .rx_tap
            .subscribeNext (playPreviousMusic)
            .addDisposableTo(disposeBag)

        musicSlider
            .rx_value
            .map { Double($0) }
            .subscribeNext (onSliderMusic)
            .addDisposableTo(disposeBag)
    }
}
