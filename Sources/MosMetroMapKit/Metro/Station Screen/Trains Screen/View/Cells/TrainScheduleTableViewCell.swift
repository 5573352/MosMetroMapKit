//
//  TrainScheduleTableViewCell.swift
//  MosmetroNew
//
//  Created by Сеня Римиханов on 07.11.2020.
//  Copyright © 2020 Гусейн Римиханов. All rights reserved.
//

import UIKit

class TrainScheduleTableViewCell: UITableViewCell {
    
    @IBOutlet weak private var mainTitleLabel : UILabel!
    @IBOutlet weak private var evenStack      : UIStackView!
    @IBOutlet weak private var oddStack       : UIStackView!
    
    var viewState: StationTrainsScheduleController.ViewState.ScheduleData! {
        didSet {
            self.mainTitleLabel.text = viewState.title
            if let first = self.evenStack.arrangedSubviews[safe: 1] as? UILabel, let last = self.evenStack.arrangedSubviews[safe: 2] as? UILabel {
                first.text = viewState.evenTimes[safe: 0] ?? ""
                last.text = viewState.evenTimes[safe: 1] ?? ""
            }
            if let first = self.oddStack.arrangedSubviews[safe: 1] as? UILabel, let last = self.oddStack.arrangedSubviews[safe: 2] as? UILabel {
                first.text = viewState.oddTimes[safe: 0] ?? ""
                last.text = viewState.oddTimes[safe: 1] ?? ""
            }
        }
    }
}
