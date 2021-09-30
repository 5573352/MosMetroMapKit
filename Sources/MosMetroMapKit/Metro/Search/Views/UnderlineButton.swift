//
//  UnderlineButton.swift
//
//  Created by Сеня Римиханов on 12.05.2020.
//

import UIKit

class UnderlineButton: UIButton {
    
    public var onTap: (() -> ())?
    
    public var isSetted: Bool = false {
        didSet {
            updateView()
        }
    }
    
    private let underline: UIView = {
        let view = UIView()
        view.roundCorners(.all, radius: 3)
        view.backgroundColor = .mm_Main
        return view
    }()
    
    //MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(underline)
        addTarget(self, action: #selector(handleTap(sender:)), for: .touchUpInside)
        underline.pin(on: self, {[
            $0.heightAnchor.constraint(equalToConstant: 2.5),
            $0.leftAnchor.constraint(equalTo: $1.safeAreaLayoutGuide.leftAnchor, constant: 0),
            $0.rightAnchor.constraint(equalTo: $1.safeAreaLayoutGuide.rightAnchor, constant: 0),
            $0.bottomAnchor.constraint(equalTo: $1.safeAreaLayoutGuide.bottomAnchor, constant: 0)
        ]})
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func updateView() {
        setTitleColor(isSetted ? .mm_TextPrimary : .mm_TextSecondary, for: .normal)
        titleLabel?.font = isSetted ? .mm_Body_17_Bold : .mm_Body_17_Regular
        underline.isHidden = isSetted ? false : true
    }
    
    @objc private func handleTap(sender: UIButton) {
        self.onTap?()
    }
}
