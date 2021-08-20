//
//  LineLoadWagonsTableViewCell.swift
//  MosmetroNew
//
//  Created by Павел Кузин on 09.12.2020.
//  Copyright © 2020 Гусейн Римиханов. All rights reserved.
//

import UIKit

// TODO: надо бы переписать
protocol _LineLoadWagonsTableViewCell {
    
}

class LineLoadWagonsTableViewCell : UITableViewCell {
    
    @IBOutlet weak var outSideView                : UIView!
    @IBOutlet weak var inSideView                 : UIView!
    @IBOutlet weak var cardView                   : UIView!
    @IBOutlet weak var arrivalLabel               : UILabel!
    @IBOutlet weak var wagonsNestedCollectionView : UICollectionView!
    
    @IBOutlet weak var collectionWidthAnchor      : NSLayoutConstraint!
    
    private var timer = Timer()
    private var hasSetTimer = false

    var timeToTrain: Int! {
        didSet {
            if !hasSetTimer {
                timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateTime), userInfo: nil, repeats: true)
                RunLoop.current.add(self.timer, forMode: RunLoop.Mode.common)
                hasSetTimer = true
            }
            arrivalLabel.text = "\("In".localized()) \(timeToTrain.asString(style: .abbreviated))"
        }
    }
    
    @objc
    private func updateTime() {
        if timeToTrain <= 0 {
            arrivalLabel.text = "Arrived".localized()
        } else {
            timeToTrain -= 1
        }
    }
    
    struct ViewState {
        let color     : UIColor
        let arrivalTime: Int
        let onSelect: () -> ()
        let wagons: [Load]
        let isStanding: Bool
        
        enum Load: String {
            case low        = "low"
            case medium     = "medium"
            case mediumHigh = "mediumHigh"
            case high       = "high"
            case unknown    = "unknown"
        }
        
        static let initial = ViewState(color: UIColor.clear, arrivalTime: 1, onSelect: {}, wagons: [], isStanding: false)
        
    }
    
    var viewState: ViewState = .initial {
        didSet {
            inSideView.backgroundColor  = viewState.color
            outSideView.backgroundColor = viewState.color
            self.timeToTrain = viewState.arrivalTime
            wagonsNestedCollectionView.reloadData()
            collectionWidthAnchor.constant = CGFloat(viewState.wagons.count * 21)
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
            flowLayout.minimumInteritemSpacing = 0.1
            flowLayout.minimumLineSpacing = 0.5
        }
        wagonsNestedCollectionView.delegate = self
        wagonsNestedCollectionView.dataSource = self
        wagonsNestedCollectionView.register(OneWagonCollectionViewCell.nib, forCellWithReuseIdentifier: OneWagonCollectionViewCell.identifire)
        cardView.layer.borderColor = UIColor.grey.withAlphaComponent(0.2).cgColor
        cardView.layer.borderWidth = 1
    }
    
    deinit {
        timer.invalidate()
    }
}

extension LineLoadWagonsTableViewCell: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewState.wagons.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: OneWagonCollectionViewCell.identifire, for: indexPath) as? OneWagonCollectionViewCell
        else { return UICollectionViewCell() }
        cell.wagonImageView.image = indexPath.row == 0 ? #imageLiteral(resourceName: "first_wagon") : #imageLiteral(resourceName: "middle_wagon")
        cell.wagonImageView.tintColor = colorForWagon(viewState.wagons[indexPath.row])
        return cell
    }
}

extension LineLoadWagonsTableViewCell: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 20, height: 8)
    }
}
