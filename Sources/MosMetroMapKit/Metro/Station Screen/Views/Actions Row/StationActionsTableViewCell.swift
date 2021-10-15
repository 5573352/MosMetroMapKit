//
//  StationActionsTableViewCell.swift
//
//  Created by Сеня Римиханов on 06.11.2020.
//

import UIKit

class StationActionsTableViewCell: UITableViewCell {
    
    @NibWrapped(MKCenteredButton.self)
    @IBOutlet private var bookmarkButton   : UIView!
    @NibWrapped(MKCenteredButton.self)
    @IBOutlet private var trainsButton     : UIView!
    @NibWrapped(MKCenteredButton.self)
    @IBOutlet private var transportsButton : UIView!
    
    var viewState: StationView.ViewState.ActionsRow! {
        didSet {
            _transportsButton.isEnabled = viewState.onTransport != nil ? true : false
            _transportsButton.isUserInteractionEnabled = viewState.onTransport != nil ? true : false
            _transportsButton.onSelect = { [weak self] in
                self?.viewState.onTransport?()
            }
            if !self.viewState.isMCD {
                _trainsButton.isEnabled = viewState.onTrains != nil ? true : false
                _trainsButton.isUserInteractionEnabled = viewState.onTrains != nil ? true : false
                _trainsButton.onSelect = { [weak self] in
                    self?.viewState.onTrains?()
                }
            } else {
                let title = NSMutableAttributedString()
                title.append(NSMutableAttributedString(string: "● ", attributes: [
                    NSAttributedString.Key.font: UIFont.systemFont(ofSize: 11),
                    NSAttributedString.Key.foregroundColor: UIColor.mm_Green
                ]))
                title.append(NSMutableAttributedString(string: NSLocalizedString("Schedule online", tableName: nil, bundle: .mm_Map, value: "", comment: ""), attributes: [
                    NSAttributedString.Key.foregroundColor: UIColor.mm_TextPrimary
                ]))
                _trainsButton.titleLabel?.attributedText = title
                _trainsButton.isEnabled = viewState.onTrains != nil ? true : false
                _trainsButton.isUserInteractionEnabled = viewState.onTrains != nil ? true : false
                _trainsButton.onSelect = { [weak self] in
                    self?.viewState.onMCD?()
                }
            }
            _bookmarkButton.isEnabled = viewState.onTransport != nil ? true : false
            _bookmarkButton.iconImageView?.image = viewState.bookmarkImage
            _bookmarkButton.titleLabel?.text = viewState.bookmarkTitle
            _bookmarkButton.onSelect = viewState.onBookmark
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        _transportsButton.iconImageView?.image = UIImage(named: "bus_template_icon", in: .mm_Map, compatibleWith: nil)!
        _transportsButton.iconImageView?.tintColor = .mm_TextPrimary
        _transportsButton.titleLabel?.text = NSLocalizedString("Exits and transport", tableName: nil, bundle: .mm_Map, value: "", comment: "")
        
        _trainsButton.iconImageView?.image = UIImage(named: "clock_template", in: .mm_Map, compatibleWith: nil)!
        _trainsButton.iconImageView?.tintColor = .mm_TextPrimary
        _trainsButton.titleLabel?.text = NSLocalizedString("Schedule", tableName: nil, bundle: .mm_Map, value: "", comment: "")
        bookmarkButton.roundCorners(.all, radius: 7)
        trainsButton.roundCorners(.all, radius: 7)
        transportsButton.roundCorners(.all, radius: 7)
    }
}
