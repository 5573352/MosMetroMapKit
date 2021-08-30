//
//  BlurControl.swift
//  PackageTester
//
//  Created by Кузин Павел on 17.08.2021.
//


import UIKit

class BlurControl: BlurView {
    
    public let iconImageView: UIImageView = {
        let button = UIImageView()
        return button
    }()
    
    public var onTap: (() -> ())?
    
    //MARK: - SetUp
    private func setup(_ buttonImage: UIImage) {
        iconImageView.image = buttonImage
        iconImageView.tintColor = .mainColor
        setupLayout()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.handleTap))
        tapGesture.numberOfTapsRequired = 1
        self.addGestureRecognizer(tapGesture)
    }
    
    //MARK: - Init
    init(frame: CGRect, cornerRadius: CGFloat, buttonImage: UIImage) {
        super.init(frame: frame, cornerRadius: cornerRadius)
        setup(buttonImage)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        print("🚧🚧🚧🚧🚧🚧🚧🚧🚧🚧🚧🚧🚧🚧")
    }
    
    @objc
    private func handleTap() {
        self.onTap?()
    }
}

//MARK: - Touches
extension BlurControl {
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        DispatchQueue.main.async {
            self.alpha = 1.0
            UIView.animate(withDuration: 0.4, delay: 0.0, options: .curveLinear, animations: {
                self.alpha = 0.5
            }, completion: nil)
        }
    }
      
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        DispatchQueue.main.async {
            self.alpha = 0.5
            UIView.animate(withDuration: 0.4, delay: 0.0, options: .curveLinear, animations: {
                self.alpha = 1.0
            }, completion: nil)
        }
    }
      
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        DispatchQueue.main.async {
            self.alpha = 0.5
            UIView.animate(withDuration: 0.4, delay: 0.0, options: .curveLinear, animations: {
                self.alpha = 1.0
            }, completion: nil)
        }
    }
}

//MARK: - Layout
extension BlurControl {
    
    private func setupLayout() {
        self.contentView.addSubview(iconImageView)
        iconImageView.pin(on: contentView, {
            [
                $0.widthAnchor.constraint(equalToConstant: 27),
                $0.heightAnchor.constraint(equalToConstant: 27),
                $0.centerYAnchor.constraint(equalTo: $1.centerYAnchor),
                $0.centerXAnchor.constraint(equalTo: $1.centerXAnchor)
            ]
        })
    }
}

