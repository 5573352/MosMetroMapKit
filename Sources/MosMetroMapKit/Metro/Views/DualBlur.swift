//
//  DualBlur.swift
//  PackageTester
//
//  Created by Кузин Павел on 17.08.2021.
//

import UIKit

class DualBlurControl: BlurView {
   
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 0
        stackView.distribution = .fillEqually
        return stackView
    }()
    
    public var onTap: ((Int) -> ())?
    
    //MARK: - SetUp
    private func setup(_ buttonImages: [UIImage]) {
        buttonImages.enumerated().forEach { (index,image) in
            let imageView = UIImageView(image: image)
            imageView.contentMode = .scaleToFill
            imageView.tintColor = .mainColor
            imageView.roundCorners(.all, radius: 8)
            
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleButtonTap(sender:)))
            tapGesture.numberOfTapsRequired = 1
            imageView.isUserInteractionEnabled = true
            imageView.addGestureRecognizer(tapGesture)
            imageView.tag = index
            stackView.addArrangedSubview(imageView)
        }
    }
    
    //MARK: - Init
    init(frame: CGRect, cornerRadius: CGFloat, buttonImages: [UIImage]) {
        super.init(frame: frame, cornerRadius: cornerRadius)
        setupLayout()
        setup(buttonImages)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc
    private func handleButtonTap(sender: UITapGestureRecognizer) {
        if let senderView = sender.view {
            self.onTap?(senderView.tag)
        }
    }
}

//MARK: - Touches
extension DualBlurControl {
    
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
extension DualBlurControl {
    
    private func setupLayout() {
        self.contentView.addSubview(stackView)
        stackView.pin(on: contentView, {
            [
                $0.topAnchor.constraint(equalTo: $1.topAnchor, constant: 0),
                $0.bottomAnchor.constraint(equalTo: $1.bottomAnchor, constant: 0),
                $0.leadingAnchor.constraint(equalTo: $1.leadingAnchor, constant: 0),
                $0.trailingAnchor.constraint(equalTo: $1.trailingAnchor, constant: 0)
            ]
        })
    }
}

