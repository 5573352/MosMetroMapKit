//
//  BasePanFullScreenController.swift
//  MosmetroNew
//
//  Created by Сеня Римиханов on 20.10.2020.
//  Copyright © 2020 Гусейн Римиханов. All rights reserved.
//

import UIKit

class BasePanController: BaseController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
    }
}

class BasePanFullScreenController: BasePanController {
    
    var onClose: (() -> ())?
    
    @IBOutlet weak var tableViewTopAnchor: NSLayoutConstraint!
    
    @IBOutlet weak var bgBlurView: UIVisualEffectView!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var closeButton: UIButton!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBAction func handleClose(_ sender: UIButton) {
        onClose?()
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        if #available(iOS 13.0, *) {
            let effect = UIBlurEffect(style: .systemMaterial)
            self.bgBlurView.effect = effect
        }
    }
}
