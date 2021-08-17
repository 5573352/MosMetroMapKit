//
//  IconView.swift
//  PackageTester
//
//  Created by Кузин Павел on 17.08.2021.
//

import UIKit

class IconButton: UIControl {
    
    enum IconAlignment {
        case left
        case right
    }
    
    public let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    
    public let actionLabel: UILabel = {
        let label = UILabel()
        label.font = .HEADER_4
        label.textColor = .white
        label.isUserInteractionEnabled = true
        return label
    }()
    
    private let viewContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isUserInteractionEnabled = false
        return view
    }()
    
    //MARK: - Init
    init(_ iconAlignment: IconAlignment, text: String, icon: UIImage, iconWidth: CGFloat, iconHeight: CGFloat) {
        super.init(frame: .zero)
        setup(iconAlignment, text: text, icon: icon, iconWidth: iconWidth, iconHeight: iconHeight)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension IconButton {
    
    private func setup(_ iconAlignment: IconAlignment, text: String, icon: UIImage, iconWidth: CGFloat, iconHeight: CGFloat) {
        
        viewContainer.addSubview(iconImageView)
        viewContainer.addSubview(actionLabel)
        iconImageView.image = icon
        addSubview(viewContainer)
        actionLabel.text = text
        switch iconAlignment {
        case .left:
            iconImageView.pin(on: self.viewContainer, {
                [
                    $0.topAnchor.constraint(equalTo: $1.topAnchor),
                    $0.leftAnchor.constraint(equalTo: $1.leftAnchor),
                    $0.heightAnchor.constraint(equalToConstant: iconHeight),
                    $0.widthAnchor.constraint(equalToConstant: iconWidth),
                ]
            })
            
            actionLabel.pin(on: self.viewContainer, {
                [
                    $0.topAnchor.constraint(equalTo: $1.topAnchor),
                    $0.leftAnchor.constraint(equalTo: iconImageView.rightAnchor, constant: 6),
                    $0.rightAnchor.constraint(equalTo: $1.rightAnchor, constant: 0),
                    $0.heightAnchor.constraint(equalToConstant: iconHeight),
                    $0.bottomAnchor.constraint(equalTo: $1.bottomAnchor, constant: 0)
                ]
            })
            
            viewContainer.pin(on: self, {
                [
                    $0.centerYAnchor.constraint(equalTo: $1.centerYAnchor),
                    $0.centerXAnchor.constraint(equalTo: $1.centerXAnchor)
                ]
            })
        case .right:
            debugPrint("right")
        }
    }
    
//    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        DispatchQueue.main.async {
//            self.alpha = 1.0
//            UIView.animate(withDuration: 0.4, delay: 0.0, options: .curveLinear, animations: {
//                self.alpha = 0.5
//            }, completion: nil)
//        }
//    }
//
//    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
//        DispatchQueue.main.async {
//            self.alpha = 0.5
//            UIView.animate(withDuration: 0.4, delay: 0.0, options: .curveLinear, animations: {
//                self.alpha = 1.0
//            }, completion: nil)
//        }
//    }
//
//    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
//        DispatchQueue.main.async {
//            self.alpha = 0.5
//            UIView.animate(withDuration: 0.4, delay: 0.0, options: .curveLinear, animations: {
//                self.alpha = 1.0
//            }, completion: nil)
//        }
//    }
    
}

