//
//  ErrorView.swift
//  MosmetroNew
//
//  Created by Сеня Римиханов on 28.06.2021.
//  Copyright © 2021 Гусейн Римиханов. All rights reserved.
//

import UIKit

class ResultView: UIView {
    
    let imageView: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "MoscowSans-Bold", size: 22)
        label.textColor = .mm_TextPrimary
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    let subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "MoscowSans-Bold", size: 15)
        label.textColor = .mm_TextSecondary
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
}

extension ResultView {
    
    private func setup() {
        backgroundColor = .clear
        imageView.pin(on: self) {[
            $0.topAnchor           .constraint(equalTo: $1.topAnchor,    constant: 0),
            $0.widthAnchor.constraint(equalToConstant: 96),
            $0.heightAnchor.constraint(equalToConstant: 96),
            $0.centerXAnchor.constraint(equalTo: $1.centerXAnchor)
        ]}
        
        titleLabel.pin(on: self) {[
            $0.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 24),
            $0.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width - 80),
            $0.leftAnchor.constraint(equalTo: $1.leftAnchor, constant: 0),
            $0.rightAnchor.constraint(equalTo: $1.rightAnchor, constant: 0),
            $0.heightAnchor.constraint(equalToConstant: 26),
            $0.centerXAnchor.constraint(equalTo: $1.centerXAnchor)
        ]}
        
        subtitleLabel.pin(on: self) {[
            $0.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            $0.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width - 80),
            $0.leftAnchor.constraint(equalTo: $1.leftAnchor, constant: 0),
            $0.rightAnchor.constraint(equalTo: $1.rightAnchor, constant: 0),
            $0.centerXAnchor.constraint(equalTo: $1.centerXAnchor),
            $0.heightAnchor.constraint(greaterThanOrEqualToConstant: 18),
            $0.bottomAnchor.constraint(equalTo: $1.bottomAnchor, constant: 0)
        ]}
    }
}
