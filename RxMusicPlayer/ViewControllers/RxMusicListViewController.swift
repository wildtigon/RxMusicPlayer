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
    var items: Variable<[RxMusic]> = Variable([])

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
            .bindTo(items)
            .addDisposableTo(disposeBag)

        items
            .asObservable()
            .bindTo(tableView.rx_itemsWithCellIdentifier("musicListCell", cellType: RxMusicViewCell.self)) { (row, element, cell) in
                cell.setData(element) }
            .addDisposableTo(disposeBag)

        tableView
            .rx_itemSelected
            .subscribeNext {
                self.performSegueWithIdentifier("segue_list_detail", sender: self)
                self.tableView.deselectRowAtIndexPath($0, animated: true) }
            .addDisposableTo(disposeBag)

        tableView
            .rx_modelSelected(RxMusic)
            .subscribeNext { print("Tapped on: \($0)") }
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
    }

    // Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "segue_list_detail" {
            guard let vc = segue.destinationViewController as? RxMusicDetailViewController else { return }
            vc.items = items
        }
    }
}
