//
//  UIViewController+Extentions.swift
//
//  Created by Павел Кузин on 07.12.2020.
//

import UIKit
import FloatingPanel

extension UIViewController {
    
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @objc
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    /// Method for adding keyboard appearance observers on the screen
    /// Use in method ViewWillAppear
    func addKeyboardObservers() {
        switch UIDevice.modelName {
        case "iPhone 5s", "iPhone 6", "iPhone 6s",
             "iPhone SE", "iPhone 7", "iPhone 8" :
            NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        default:
            return
        }
    }
    
    /// Method for remove keyboard appearance observers on the screen
    /// Use in method ViewWillDisappear
    func removeKeyboardObservers() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc
    private func keyboardWillShow(notification: NSNotification) {
        if self.view.frame.origin.y == 0 {
            self.view.frame.origin.y -= 32
        }
    }
    
    @objc
    private func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }
    
}
