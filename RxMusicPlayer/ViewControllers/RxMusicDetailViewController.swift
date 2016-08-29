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
    weak var itemsMusic: Variable<[RxMusicViewModel]>!

    var currentMusic: RxMusicViewModel!

    var musicDurationTimer: NSTimer?
    var streamer: DOUAudioStreamer!
    var visualEffectView: UIVisualEffectView!

    var isPlaying = false

    var currentIndex: Int = 0 {
        willSet {
            if (currentMusic != nil) {
                currentMusic.isPlaying.onNext(false)
            }
        }

        didSet {
            currentMusic = itemsMusic.value[currentIndex]
        }
    }

    var specialIndex = 0

    var kStatusContext: UInt8 = 1
    var kDurationContext: UInt8 = 1
    var kBufferingRatioContext: UInt8 = 1

    var bag: DisposeBag!

    let musicCycleType: Variable<MusicCycleType> = Variable(.LoopAll)

    // Constants
    let musicIndicator = RxMusicIndicator.shareInstance

    // Life cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        initWidget()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        createStream()
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        removeStreamerObserver()
        bag = nil
    }
}

// Music Behavior
extension RxMusicDetailViewController {
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
        let musicCount = itemsMusic.value.count

        if musicCount == 1 {
            print("Just one song")
            return
        }

        if musicCycleType.value == .Shuffle && musicCount > 2 {
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
        let musicCount = itemsMusic.value.count

        if musicCount == 1 {
            print("Just one song")
            return
        }

        if musicCycleType.value == .Shuffle && musicCount > 2 {
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
}

// Music Core
extension RxMusicDetailViewController {
    private func createStream() {
        // init index
        if (specialIndex > 0) {
            currentIndex = specialIndex
            specialIndex = 0
        }

        bindingUI()

        // init track
        let filename = try? currentMusic.fileName.value()

        guard let soundFilePath = NSBundle.mainBundle().pathForResource(filename, ofType: "mp3") else { return }
        let fileURL = NSURL(fileURLWithPath: soundFilePath)

        let track = RxTrack()
        track.url = fileURL

        removeStreamerObserver()

        streamer = DOUAudioStreamer(audioFile: track)

        addStreamerObserver()
        streamer.play()
    }

    private func updateStatus() {
        isPlaying = false
        musicIndicator.state = .Stopped
        switch streamer.status {
        case .Playing:
            currentMusic.isPlaying.onNext(true)
            isPlaying = true

            musicIndicator.state = .Playing

            musicToggleButton.startDuangAnimation()
            musicToggleButton.selected = false
            break

        case .Paused:
            musicToggleButton.startDuangAnimation()
            musicToggleButton.selected = true
            currentMusic.isPlaying.onNext(false)
            break

        case .Idle:
            break

        case .Finished:
            if musicCycleType.value == .LoopSingle {
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

    private func invalidateDurationTimer() {
        if musicDurationTimer != nil && musicDurationTimer!.valid {
            musicDurationTimer?.invalidate()
        }
        musicDurationTimer = nil
    }

    private func updateSliderValue() {
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
}

// Music Observer
extension RxMusicDetailViewController {
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
}

// UI
extension RxMusicDetailViewController {
    private func updateProgressLabelValue() {
        beginTimeLabel.text = String.timeIntervalToMMSSFormat(streamer.currentTime)
        endTimeLabel.text = String.timeIntervalToMMSSFormat(streamer.duration)
    }

    private func bindingUI() {
        // Dispose all of observable
        bag = nil
        bag = DisposeBag()

        // Binding UI
        currentMusic.isFavorite
            .asObservable()
            .bindTo(favoriteButton.rx_selected)
            .addDisposableTo(bag)

        currentMusic.name
            .bindTo(musicNameLabel.rx_text)
            .addDisposableTo(bag)

        currentMusic.artistName
            .bindTo(singerLabel.rx_text)
            .addDisposableTo(bag)

        currentMusic.cover
            .subscribeNext(setupBackground)
            .addDisposableTo(bag)

        Observable<IntegerLiteralType>
            .interval(1, scheduler: MainScheduler.instance)
            .map { _ in }
            .subscribeNext (updateSliderValue)
            .addDisposableTo(bag)
    }

    private func initWidget() {
        musicTitleLabel.text = ""

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

        musicCycleButton
            .rx_tap
            .map { self.musicCycleType.value }
            .map {
                switch $0 {
                case .Shuffle:
                    return .LoopAll
                case .LoopAll:
                    return .LoopSingle
                default:
                    return .Shuffle } }
            .bindTo(musicCycleType)
            .addDisposableTo(disposeBag)

        // for nsuserdefault
        musicCycleType
            .asObservable()
            .subscribeOn(MainScheduler.instance)
            .subscribeNext {
                switch $0 {
                case .LoopSingle:
                    self.musicCycleButton.setImageWithImageName("loop_single_icon")
                    break
                case .LoopAll:
                    self.musicCycleButton.setImageWithImageName("loop_all_icon")
                    break
                default:
                    self.musicCycleButton.setImageWithImageName("shuffle_icon")
                    break } }
            .addDisposableTo(disposeBag)

        favoriteButton
            .rx_tap
            .map { !self.favoriteButton.selected }
            .subscribeNext {
                self.favoriteButton.startDuangAnimation()
                self.currentMusic.isFavorite.onNext($0) }
            .addDisposableTo(disposeBag)

        albumImageView.layer.cornerRadius = 7
        albumImageView.layer.masksToBounds = true
    }

    private func setupBackground(cover: String) {
        let width = Int((Screen.WIDTH - 70) * 2)
        let url = NSURL.qiniuImageCenter(cover, width, 0)

        // download image
        let imagePlaceHolder = UIImage(named: "music_placeholder")

        backgroudImageView
            .sd_setImageWithURL(url, placeholderImage: imagePlaceHolder, options: [.RefreshCached, .RetryFailed]) { (image, _, _, _) in
                self.backgroudImageView.alpha = 0;
                UIView.animateWithDuration(0.25, animations: {
                    self.backgroudImageView.alpha = 1
                })
        }

        albumImageView
            .sd_setImageWithURL(url, placeholderImage: imagePlaceHolder, options: [.RefreshCached, .RetryFailed]) { (image, _, _, _) in
                self.albumImageView.alpha = 0;
                UIView.animateWithDuration(0.75, animations: {
                    self.albumImageView.alpha = 1
                })
        }

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
}
