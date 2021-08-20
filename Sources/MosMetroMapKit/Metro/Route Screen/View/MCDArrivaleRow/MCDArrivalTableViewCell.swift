//
//  MCDArrivalTableViewCell.swift
//  MosmetroNew
//
//  Created by Павел Кузин on 16.12.2020.
//  Copyright © 2020 Гусейн Римиханов. All rights reserved.
//

import UIKit

class MCDArrivalTableViewCell: UITableViewCell {
    
    static let reuseID = "MCDArrivalTableViewCell"
    
    @IBOutlet weak var firstStationLabel : UILabel!
    @IBOutlet weak var collectionView    : UICollectionView!
    
    struct ViewState {
        
        let towards: String
        let items: [MCDArrivaleCollectionViewCell.ViewState]
        
        static let initial = ViewState(towards: "", items: [])
    }
    
    var viewState: ViewState = .initial {
        didSet {
            self.firstStationLabel.text = viewState.towards
            self.collectionView.reloadData()
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .clear
        
        if let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.sectionInset = UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20)
            flowLayout.minimumInteritemSpacing = 12
            flowLayout.minimumLineSpacing = 12
            flowLayout.scrollDirection = .horizontal
            flowLayout.itemSize = CGSize(width: 150, height: 60)
        }
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.alwaysBounceVertical = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(UINib(nibName: "MCDArrivaleCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: MCDArrivaleCollectionViewCell.reuseID)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}

extension MCDArrivalTableViewCell: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewState.items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let item = viewState.items[safe: indexPath.row] else { return UICollectionViewCell() }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MCDArrivaleCollectionViewCell.reuseID, for: indexPath) as! MCDArrivaleCollectionViewCell
        cell.viewState = item
        return cell
    }
}

extension MCDArrivalTableViewCell {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let data = viewState.items[indexPath.row]
        data.onSelect()
    }
}

extension MCDArrivalTableViewCell: UICollectionViewDelegate {
    
}
