//
//  BaseController.swift
//  MosmetroClip
//
//  Created by Павел Кузин on 13.04.2021.
//  Copyright © 2021 Гусейн Римиханов. All rights reserved.
//

import UIKit
import FloatingPanel
import Localize_Swift

public class BaseController: UIViewController {
    
    var floatingPanelController : FloatingPanelController!
    
    var onLanguageChange: (() -> ())?
    
    lazy var visualEffectView: UIVisualEffectView? = {
        let blurEffect = UIBlurEffect(style: .dark)
        let view = UIVisualEffectView(effect: blurEffect)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    public override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(setText), name: NSNotification.Name(LCLLanguageChangeNotification), object: nil)
        self.view.backgroundColor = UIColor.MKBase
        let backBarButtton = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem = backBarButtton
    }
    
    @objc
    func setText() {
        onLanguageChange?()
    }
}

extension BaseController : FloatingPanelControllerDelegate {
    
    func setTransparentNavBar() {
           self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
           self.navigationController?.navigationBar.shadowImage   = UIImage()
           self.navigationController?.navigationBar.isTranslucent = true
           self.navigationController?.view.backgroundColor        = .clear
       }
}
