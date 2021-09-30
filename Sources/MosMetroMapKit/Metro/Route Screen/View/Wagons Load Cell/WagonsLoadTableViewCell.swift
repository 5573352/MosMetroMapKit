//
//  WagonsLoadTableViewCell.swift
//  MosmetroNew
//
//  Created by Сеня Римиханов on 06.08.2020.
//  Copyright © 2020 Гусейн Римиханов. All rights reserved.
//

import UIKit

class WagonsLoadTableViewCell: UITableViewCell {
    
    static let reuseID = "WagonsLoadTableViewCell"
    
    @IBOutlet weak var firstStationLabel: UILabel!
    @IBOutlet weak var wagonsCollectionView: UICollectionView!
    
    struct ViewState {
        
        let towards: String
        let items: [WagonLoadCollectionViewCell.ViewState]
        
        static let initial = ViewState(towards: "", items: [])
    }
    
    var viewState: ViewState = .initial {
        didSet {
            self.firstStationLabel.text = viewState.towards
            self.wagonsCollectionView.reloadData()
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        wagonsCollectionView.dataSource = self
        wagonsCollectionView.delegate = self
        wagonsCollectionView.register(WagonLoadCollectionViewCell.nib, forCellWithReuseIdentifier: WagonLoadCollectionViewCell.identifire)
    }
}

extension WagonsLoadTableViewCell: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewState.items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let item = viewState.items[safe: indexPath.row] else { return UICollectionViewCell() }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: WagonLoadCollectionViewCell.identifire, for: indexPath) as! WagonLoadCollectionViewCell
        cell.viewState = item
        return cell
    }
}

extension WagonsLoadTableViewCell: UICollectionViewDelegate {
    
}

extension WagonsLoadTableViewCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let item = viewState.items[safe: indexPath.row] else { return CGSize.zero }
        return CGSize(width: item.wagons.count * 36 + 32, height: 74)
    }
}
