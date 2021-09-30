//
//  StationSelectionView.swift
//
//  Created by Сеня Римиханов on 10.05.2020.
//

import UIKit

class StationSelectionView: UIView {
    
    public let fromTextField = StationSelectTextField()
    public let toTextField = StationSelectTextField()
    
    var onTap: ((Direction) -> ())?
    var onClear: ((Direction) -> ())?
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
        
        
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
        
    }
    
}

extension StationSelectionView {
    
    
    private func setup() {
        layer.masksToBounds = false
        backgroundColor = .MKBase
        addSubview(stackView)
        roundCorners(.all, radius: 8)
        stackView.pin(on: self, {
                    [
                        $0.topAnchor.constraint(equalTo: $1.topAnchor, constant: 3) ,
                        $0.leftAnchor.constraint(equalTo: $1.leftAnchor, constant: 3),
                        $0.rightAnchor.constraint(equalTo: $1.rightAnchor, constant: -3),
                        $0.bottomAnchor.constraint(equalTo: $1.bottomAnchor, constant: -3),
                    ]
                })
        
        fromTextField.viewState = .initialFrom
        toTextField.viewState = .initialTo
        fromTextField.onTap = { [weak self] in
            guard let self = self else { return }
            self.onTap?(.from)
        }
        
        fromTextField.onClear = { [weak self] in
            guard let self = self else { return }
            self.onClear?(.from)
        }
        
        toTextField.onTap = { [weak self] in
            guard let self = self else { return }
            self.onTap?(.to)
        }
        
        toTextField.onClear = { [weak self] in
            guard let self = self else { return }
            self.onClear?(.to)
        }
        
        stackView.addArrangedSubview(fromTextField)
        stackView.addArrangedSubview(toTextField)
        layer.masksToBounds = false
        layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.16).cgColor
        layer.shadowOpacity = 1
        layer.shadowRadius = 12
        layer.shadowOffset = CGSize(width: 0, height: 0)

    }
}
