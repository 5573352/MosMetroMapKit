//
//  String+Extentions.swift
//
//  Created by Павел Кузин on 07.12.2020.
//

import UIKit

extension String {
    
    var htmlToAttributedString: NSAttributedString? {
        guard let data = data(using: .utf8) else { return NSAttributedString() }
        do {
            return try NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding:String.Encoding.utf8.rawValue], documentAttributes: nil)
        } catch {
            return NSAttributedString()
        }
    }
    
    var htmlToString: String {
        return htmlToAttributedString?.string ?? ""
    }
    
    /**
        Method capitalized first letter in a string
    */
    func capitalizingFirstLetter() -> String {
        return prefix(1).capitalized + dropFirst()
    }

    /**
        Method capitalized first letter in a string
    */
    mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
    
    func toAttributed(color: UIColor, font: UIFont) -> NSMutableAttributedString {
        let attributedString = NSMutableAttributedString(string: self)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 8
        attributedString.addAttributes([NSAttributedString.Key.paragraphStyle: paragraphStyle, NSAttributedString.Key.foregroundColor: color,  NSAttributedString.Key.font: font], range: NSMakeRange(0, attributedString.length))
        return attributedString
    }
}

extension NSMutableAttributedString {
    
    /**
     Method for
     */
    func setFontFace(font: UIFont, color: UIColor? = nil) {
        beginEditing()
        self.enumerateAttribute(.font, in: NSRange(location: 0, length: self.length)) { (value, range, stop) in
            if let f = value as? UIFont, let newFontDescriptor = f.fontDescriptor.withFamily(font.familyName).withSymbolicTraits(f.fontDescriptor.symbolicTraits) {
                let newFont = UIFont(descriptor: newFontDescriptor, size: font.pointSize)
                removeAttribute(.font, range: range)
                addAttribute(.font, value: newFont, range: range)
                                if let color = color {
                                    removeAttribute(.foregroundColor, range: range)
                                    addAttribute(.foregroundColor, value: color, range: range)
                                }
            }
        }
        endEditing()
    }
}
