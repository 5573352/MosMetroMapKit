//
//  StationTextField.swift
//  MosmetroNew
//
//  Created by Сеня Римиханов on 07.05.2020.
//  Copyright © 2020 Гусейн Римиханов. All rights reserved.
//

import UIKit

public class StationSelectTextField: UIView {
    
    public var onTap: (() -> ())?
    public var onClear: (() -> ())?
    
    private var colorForGradient: UIColor?
    
    
    private let blurGradient: CAGradientLayer = {
        let gradient = CAGradientLayer()
        gradient.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
        gradient.colors = [UIColor.clear.withAlphaComponent(0.0).cgColor, UIColor.clear.withAlphaComponent(0.8).cgColor, UIColor.clear.withAlphaComponent(0.9).cgColor]
        gradient.locations = [0.0, 0.2, 1.0]
        gradient.startPoint = CGPoint(x: 0.0, y: 0.5);
        gradient.endPoint = CGPoint(x: 1.0, y: 0.5);
        return gradient
    }()
    
    
    struct ViewState {
        let color: UIColor
        let image: UIImage?
        let title: String
        let onTap: () -> ()
        let onClear: () -> ()
        
        static let initialFrom = ViewState(color: .MKTextfield, image: nil, title: NSLocalizedString("From", tableName: nil, bundle: .mm_Map, value: "", comment: ""), onTap: {} ,onClear: {})
        static let initialTo = ViewState(color: .MKTextfield, image: nil, title: NSLocalizedString("To", tableName: nil, bundle: .mm_Map, value: "", comment: ""), onTap: {} ,onClear: {})
    }
    
    
    
    var viewState: ViewState! {
        didSet {
            updateView()
        }
    }
    
    private func updateView() {
        eraseButton.isHidden = viewState.image == nil ? true : false
        eraseButton.isUserInteractionEnabled = viewState.image == nil ? false : true
        backgroundColor = viewState.color
        stationLabel.text = viewState.title
        stationLabel.textColor = viewState.image == nil ? .grey : .white
        circleView.image = viewState.image
        circleView.backgroundColor = viewState.image == nil ? .grey : .clear
        blurGradient.colors = [viewState.color.withAlphaComponent(0.0).cgColor, viewState.color.withAlphaComponent(0.8).cgColor, viewState.color.withAlphaComponent(0.9).cgColor]
        blurView.isHidden = viewState.image == nil ? true : false
    }
    
    
  
    
    private let circleView: UIImageView = {
        
        let returnView = UIImageView()
        returnView.roundCorners(.all, radius: 9.5)
        returnView.backgroundColor = .grey
        returnView.contentMode = .scaleAspectFit
        returnView.translatesAutoresizingMaskIntoConstraints = false
        return returnView
    }()
    
    private let stationLabel: UILabel = {
        let label = UILabel()
        label.alpha = 1
        label.backgroundColor = .clear
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Placeholsddsdssdsdder"
        label.textColor = .grey
        label.font = .BODY_XS_BOLD
        label.lineBreakMode = .byClipping
        label.isUserInteractionEnabled = true
        return label
        
    }()
    
    private let eraseButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(#imageLiteral(resourceName: "selection_view_close"), for: .normal)
        button.contentMode = .center
        button.backgroundColor = .clear
        button.imageEdgeInsets = UIEdgeInsets(top: 2, left: 0, bottom: 0, right: -5)

        button.isHidden = true
        button.isUserInteractionEnabled = false
        return button
    }()
    
    
    
    private let tapAreaButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .clear
        return button
    }()
    
    private let blurView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.clear
        view.isHidden = true
        
        return view
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    
    
}

extension StationSelectTextField {
    
    @objc
    private func handleTap(_ sender: UIButton) {
        self.viewState.onTap()
    }
    
    @objc
    private func handleErase(_ sender: UIButton) {
        self.viewState.onClear()
    }
    
    private func setup() {
        backgroundColor = .MKTextfield
        translatesAutoresizingMaskIntoConstraints = false
        layer.cornerRadius = 6
        addSubview(circleView)
        addSubview(stationLabel)
        addSubview(blurView)
        blurView.layer.addSublayer(blurGradient)
        addSubview(tapAreaButton)
        addSubview(eraseButton)
        
        tapAreaButton.addTarget(self, action: #selector(handleTap(_:)), for: .touchUpInside)
        eraseButton.addTarget(self, action: #selector(handleErase(_:)), for: .touchUpInside)
        self.setConstraints()
    }
    
    private func setConstraints() {
        
        circleView.pin(on: self, {
            [
                $0.widthAnchor.constraint(equalToConstant: 19),
                $0.heightAnchor.constraint(equalToConstant: 19),
                $0.leftAnchor.constraint(equalTo: $1.leftAnchor, constant: 8),
                $0.centerYAnchor.constraint(equalTo: centerYAnchor),
            ]
        })
        
        stationLabel.pin(on: self, {
            [
                $0.topAnchor.constraint(equalTo: $1.topAnchor, constant: 11) ,
                $0.leftAnchor.constraint(equalTo: circleView.rightAnchor, constant: 6),
                $0.rightAnchor.constraint(equalTo: $1.rightAnchor, constant: -16),
                $0.bottomAnchor.constraint(equalTo: $1.bottomAnchor, constant: -9),
            ]
        })
        
        
        tapAreaButton.pin(on: self, {
            [
                $0.topAnchor.constraint(equalTo: $1.topAnchor, constant: 0) ,
                $0.leftAnchor.constraint(equalTo: $1.leftAnchor, constant: 0),
                $0.rightAnchor.constraint(equalTo: $1.rightAnchor, constant: -16),
                $0.bottomAnchor.constraint(equalTo: $1.bottomAnchor, constant: 0),
            ]
        })
        
        blurView.pin(on: self, {
            [
                $0.centerYAnchor.constraint(equalTo: $1.centerYAnchor),
                $0.rightAnchor.constraint(equalTo: $1.rightAnchor, constant: -9),
                $0.widthAnchor.constraint(equalToConstant: 20),
                $0.heightAnchor.constraint(equalToConstant: 20),
                
            ]
        })
        
        eraseButton.pin(on: self, {
            [
                $0.centerYAnchor.constraint(equalTo: $1.centerYAnchor),
                $0.rightAnchor.constraint(equalTo: $1.rightAnchor, constant: 0),
                $0.widthAnchor.constraint(equalTo: $1.heightAnchor),
                $0.heightAnchor.constraint(equalTo: $1.heightAnchor),
                
            ]
        })
        
        
        
        
    }
    
}

