//
//  BaseNavigationController.swift
//  
//
//  Created by Кузин Павел on 24.08.2021.
//

import UIKit

//MARK: - Preferred Status Bar Style
extension UINavigationController {
    
   open override var preferredStatusBarStyle: UIStatusBarStyle {
      return topViewController?.preferredStatusBarStyle ?? .default
   }
}

class BaseNavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationBar.isTranslucent          = false
        self.navigationBar.prefersLargeTitles     = false
        self.navigationItem.largeTitleDisplayMode = .automatic
        self.view.backgroundColor       = .navigationBar
        self.navigationBar.barTintColor = .navigationBar
        self.navigationBar.tintColor    = .mm_TextPrimary
        setTitleApearence()
    }
    
    public func setTransparent() {
        if #available(iOS 13.0, *) {
            self.navigationBar.standardAppearance.backgroundColor = .clear
            self.navigationBar.compactAppearance?   .configureWithTransparentBackground()
            self.navigationBar.standardAppearance   .configureWithTransparentBackground()
            self.navigationBar.scrollEdgeAppearance?.configureWithTransparentBackground()
        } else {
            // Fallback on earlier versions
        }
    }
    
    public func setTitleApearence() {
        let largeTitle   = [NSAttributedString.Key.font: UIFont.HEADER_1, NSAttributedString.Key.foregroundColor: UIColor.mm_TextPrimary]
        let defaultTitle = [NSAttributedString.Key.font: UIFont.HEADER_3, NSAttributedString.Key.foregroundColor: UIColor.mm_TextPrimary]
        
        if #available(iOS 13.0, *) {
            let appereance = UINavigationBarAppearance()
            appereance.backgroundColor              = .navigationBar
            appereance.shadowColor                  = .clear
            appereance.largeTitleTextAttributes     = largeTitle
            appereance.titleTextAttributes          = defaultTitle
            appereance.setBackIndicatorImage(#imageLiteral(resourceName: "nav_back_icon"), transitionMaskImage: #imageLiteral(resourceName: "nav_back_icon"))

            self.navigationBar.standardAppearance   = appereance
            self.navigationBar.compactAppearance    = appereance
            self.navigationBar.scrollEdgeAppearance = self.navigationBar.standardAppearance

        } else {
            self.navigationBar.titleTextAttributes      = defaultTitle
            self.navigationBar.largeTitleTextAttributes = largeTitle
        }
        
        navigationBar.barTintColor = .navigationBar
    }
    
    deinit {

    }
}
