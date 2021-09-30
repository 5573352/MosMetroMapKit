//
//  BasePanView.swift
//
//  Created by Сеня Римиханов on 13.05.2020.
//

import UIKit

class BasePanBackgroundView : UIView {
    
    private lazy var backgroundBlur: UIVisualEffectView = {
        let visualView = UIVisualEffectView()
        let effect = UIBlurEffect(style: .prominent)
        visualView.effect = effect
        return visualView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        if #available(iOS 13.0, *) {
            let effect = UIBlurEffect(style: .systemMaterial)
            self.backgroundBlur.effect = effect
        } else {
            
        }
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//MARK: - Layout
extension BasePanBackgroundView {
    
    private func setupLayout() {
        addSubview(backgroundBlur)
        backgroundBlur.pin(on: self, {[
            $0.topAnchor.constraint(equalTo: $1.topAnchor, constant: 0) ,
            $0.leftAnchor.constraint(equalTo: $1.leftAnchor, constant: 0),
            $0.rightAnchor.constraint(equalTo: $1.rightAnchor, constant: 0),
            $0.bottomAnchor.constraint(equalTo: $1.bottomAnchor, constant: 0),
        ]})
    }
}
