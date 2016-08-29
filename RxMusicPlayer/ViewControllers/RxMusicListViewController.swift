//
//  RxMusicListViewController.swift
//  RxMusicPlayer
//
//  Created by Nguyễn Tiến Đạt on 8/25/16.
//  Copyright © 2016 Nguyễn Tiến Đạt. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class RxMusicListViewController: RxBaseViewController {

    // IBOutlets
    @IBOutlet weak var tableView: UITableView!

    // Variables
    var itemsMusic: Variable<[RxMusicViewModel]> = Variable([])

    // Constants
    let musicRequest = RxMusicModel.shareInstance.getMusic()
    let indicator = RxMusicIndicator.shareInstance

    // Life cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        initNavigationBarWithText("RxPlayMusic")
        initIndicatorView()
        initWidget()
    }

    // Functions
    private func initWidget() {
        tableView.rowHeight = 57

        musicRequest
            .bindTo(itemsMusic)
            .addDisposableTo(disposeBag)

        itemsMusic
            .asObservable()
            .bindTo(tableView.rx_itemsWithCellIdentifier("musicListCell", cellType: RxMusicViewCell.self)) { (row, element, cell) in
                cell.musicInfo = element }
            .addDisposableTo(disposeBag)

        tableView
            .rx_itemSelected
            .subscribeNext {
                let vc = RxMusicDetailViewController.sharedInstance()
                vc.itemsMusic = self.itemsMusic
                vc.currentIndex = $0.row

                self.navigationController?.presentViewController(vc, animated: true, completion: nil)
                self.tableView.deselectRowAtIndexPath($0, animated: true) }
            .addDisposableTo(disposeBag)
    }

    private func initIndicatorView() {
        indicator.hidesWhenStopped = false
        indicator.tintColor = .purpleColor()

        if indicator.state != .Playing {
            indicator.state = .Playing
            indicator.state = .Stopped
        } else {
            indicator.state = .Playing
        }

        navigationController?.navigationBar.addSubview(indicator)

        // Add gesture
        let tapIndicator = UITapGestureRecognizer(target: self, action: #selector(handleTapIndicator))
        tapIndicator.numberOfTapsRequired = 1
        indicator.addGestureRecognizer(tapIndicator)
    }

    @objc private func handleTapIndicator() {
        print("tap tap")
        let array = itemsMusic.value

        for item in array {
            print("Item: \(try! item.name.value()) isFavorite: \(try! item.isFavorite.value())")
        }
    }
}
