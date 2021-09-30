//
//  WagonLoadCollectionViewCell.swift
//  MosmetroNew
//
//  Created by Сеня Римиханов on 06.08.2020.
//  Copyright © 2020 Гусейн Римиханов. All rights reserved.
//

import UIKit
import SwiftDate

class WagonLoadCollectionViewCell : UICollectionViewCell {
    
    @IBOutlet weak var cardView                   : UIView!
    @IBOutlet weak var arrivalLabel               : UILabel!
    @IBOutlet weak var wagonsNestedCollectionView : UICollectionView!
    
    private var hasSetTimer = false
    private var timer = Timer()
    
    var timeToTrain: Int! {
        didSet {
            if !hasSetTimer {
                timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateTime), userInfo: nil, repeats: true)
                RunLoop.current.add(self.timer, forMode: RunLoop.Mode.common)
                hasSetTimer = true
            }
            arrivalLabel.text = "\(NSLocalizedString("In", tableName: nil, bundle: .mm_Map, value: "", comment: "")) \(timeToTrain.asString(style: .abbreviated))"
        }
    }
    
    @objc
    private func updateTime() {
        if timeToTrain <= 0 {
            arrivalLabel.text = NSLocalizedString("Arrived", tableName: nil, bundle: .mm_Map, value: "", comment: "")
        } else {
            timeToTrain -= 1
        }
    }
    
    struct ViewState {
        let arrivalTime: Int
        let onSelect: () -> ()
        let wagons: [Load]
        let isStanding: Bool
        
        enum Load: String {
            case low = "low"
            case medium = "medium"
            case mediumHigh = "mediumHigh"
            case high = "high"
            case unknown = "unknown"
        }
        
        static let initial = ViewState(arrivalTime: 1, onSelect: {}, wagons: [], isStanding: false)
        
    }
    
    var viewState: ViewState = .initial {
        didSet {
            self.timeToTrain = viewState.arrivalTime
            wagonsNestedCollectionView.reloadData()
        }
    }
    
    private func colorForWagon(_ load: ViewState.Load) -> UIColor {
        if case .unknown = load {
            return .grey
        } else {
           return UIColor(named: load.rawValue) ?? UIColor.grey
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        cardView.roundCorners(.all, radius: 8)
        if let flowLayout = wagonsNestedCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.minimumInteritemSpacing = 0.5
            flowLayout.minimumLineSpacing = 0.5
        }
        wagonsNestedCollectionView.dataSource = self
        wagonsNestedCollectionView.delegate = self
        wagonsNestedCollectionView.register(OneWagonCollectionViewCell.nib, forCellWithReuseIdentifier: OneWagonCollectionViewCell.identifire)
    }
    
    deinit {
        timer.invalidate()
    }
    
}

extension WagonLoadCollectionViewCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewState.wagons.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: OneWagonCollectionViewCell.identifire, for: indexPath) as! OneWagonCollectionViewCell
        
        cell.wagonImageView.image = indexPath.row == 0 ? UIImage(named: "first_wagon", in: .mm_Map, compatibleWith: nil)! : UIImage(named: "middle_wagon", in: .mm_Map, compatibleWith: nil)!
    
        cell.wagonImageView.tintColor = colorForWagon(viewState.wagons[indexPath.row])
        return cell
    }
    
    
}

extension WagonLoadCollectionViewCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
            return CGSize(width: 35, height: 14)
        
    }
}
