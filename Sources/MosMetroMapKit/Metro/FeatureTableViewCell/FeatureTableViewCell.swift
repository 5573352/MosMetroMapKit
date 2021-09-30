//
//  FeatureTableViewCell.swift
//
//  Created by Сеня Римиханов on 15.07.2020.
//

import UIKit

class FeatureTableViewCell: UITableViewCell {
    
    static let reuseID = "FeatureTableViewCell"
    
    @IBOutlet weak var firstFeatureImageView: UIImageView!
    @IBOutlet weak var firstFeatureLabel: UILabel!
    
    @IBOutlet weak var secondFeatureImageView: UIImageView!
    @IBOutlet weak var secondFeatureLabel: UILabel!
    
    struct ViewState   {
        let first      : Feature?
        let second     : Feature?
        
        struct Feature {
            let image  : UIImage
            let title  : String
        }
        
        static let initial = ViewState(first: Feature(image: UIImage(named: "bookmark", in: .mm_Map, compatibleWith: nil)!, title: ""), second: Feature(image: UIImage(named: "bookmark", in: .mm_Map, compatibleWith: nil)!, title: ""))
    }
    
    public var viewState: ViewState = .initial {
        didSet {
            render()
        }
    }
    
    private func render() {
        if let first = viewState.first {
            self.firstFeatureLabel.isHidden = false
            self.firstFeatureImageView.isHidden = false
            self.firstFeatureLabel.text = first.title
            self.firstFeatureImageView.image = first.image
        } else {
            self.firstFeatureLabel.isHidden = true
            self.firstFeatureImageView.isHidden = true
        }
        
        if let second = viewState.second {
            self.secondFeatureLabel.isHidden = false
            self.secondFeatureImageView.isHidden = false
            self.secondFeatureLabel.text = second.title
            self.secondFeatureImageView.image = second.image
        } else {
            self.secondFeatureLabel.isHidden = true
            self.secondFeatureImageView.isHidden = true
        }
        firstFeatureLabel.sizeToFit()
        secondFeatureLabel.sizeToFit()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        firstFeatureLabel.font = .mm_Body_13_Bold
        secondFeatureLabel.font = .mm_Body_13_Bold
        firstFeatureImageView.tintColor = .mm_TextPrimary
        secondFeatureImageView.tintColor = .mm_TextPrimary
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
}
