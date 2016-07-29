//
//  ViewController.swift
//  StringAttributeDemo
//
//  Created by Ryunosuke Kirikihira on 2016/02/16.
//  Copyright © 2016年 Krimpedance. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var textLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let ja = UIFont(name: "HiraginoSans-W3", size: 20)
        let en = UIFont(name: "BodoniSvtyTwoITCTT-Book", size: 20)
        let num = UIFont(name: "SnellRoundhand", size: 20)
//        self.textLabel.attributedText = self.textLabel.text?.attributedString(japaneseFont: ja, englishFont: en, numericFont: num, transformEnglish: true, transformNumeric: true)
        self.textLabel.attributedText = self.textLabel.text?.attributedString(japaneseColor: UIColor.redColor(), englishColor: UIColor.greenColor(), numericColor: UIColor.blueColor(), otherColor: UIColor.grayColor(), transforms: [.English, .Numeric])
    }
}

extension String {
    enum CharacterType {
        case Numeric, English, Katakana, Other
    }

    func attributedString(
        japaneseFont jaFont :UIFont?=nil,
        englishFont enFont :UIFont?=nil,
        numericFont numFont :UIFont?=nil,
        otherFont :UIFont?=nil,
        japaneseColor jaColor :UIColor?=nil,
        englishColor enColor :UIColor?=nil,
        numericColor numColor :UIColor?=nil,
        otherColor :UIColor?=nil,
        transforms :[CharacterType] = []
    ) -> NSAttributedString {
        var text :String = self
        
        if let type = transforms.filter({$0 == .Numeric}).first { text = text.transformFullwidthHalfwidth(transformTypes: [type])}
        if let type = transforms.filter({$0 == .English}).first { text = text.transformFullwidthHalfwidth(transformTypes: [type])}
        if let type = transforms.filter({$0 == .Katakana}).first { text = text.transformFullwidthHalfwidth(transformTypes: [type])}
        if let type = transforms.filter({$0 == .Other}).first { text = text.transformFullwidthHalfwidth(transformTypes: [type])}
        
        let attributedString = NSMutableAttributedString(string: text)
        let chars = text.characters.map{ String($0) }
        
        chars.enumerate().forEach{ index, str in
            if str.isKatakana() {
                if let font = jaFont { attributedString.setAttributes([NSFontAttributeName : font], range: NSRange(location: index, length: 1)) }
                if let color = jaColor { attributedString.setAttributes([NSForegroundColorAttributeName : color], range: NSRange(location: index, length: 1)) }
            }
            else if str.isNumber(transformHalfwidth: true) {
                if let font = numFont { attributedString.setAttributes([NSFontAttributeName : font], range: NSRange(location: index, length: 1)) }
                if let color = numColor { attributedString.setAttributes([NSForegroundColorAttributeName : color], range: NSRange(location: index, length: 1)) }
            }
            else if str.isEnglish(transformHalfwidth: true) {
                if let font = enFont { attributedString.setAttributes([NSFontAttributeName : font], range: NSRange(location: index, length: 1)) }
                if let color = enColor { attributedString.setAttributes([NSForegroundColorAttributeName : color], range: NSRange(location: index, length: 1)) }
            }
            else {
                if let font = otherFont { attributedString.setAttributes([NSFontAttributeName : font], range: NSRange(location: index, length: 1)) }
                if let color = otherColor { attributedString.setAttributes([NSForegroundColorAttributeName : color], range: NSRange(location: index, length: 1)) }
            }
        }
        
        return attributedString
    }
    
    func transformFullwidthHalfwidth(transformTypes types :[CharacterType], reverse :Bool=false) -> String {
        var transformedChars :[String] = []
       
        let chars = self.characters.map{ String($0) }
        chars.forEach{
            let halfwidthChar = NSMutableString(string: $0) as CFMutableString
            CFStringTransform(halfwidthChar, nil, kCFStringTransformFullwidthHalfwidth, false)
            let char = halfwidthChar as String
            
            if char.isNumber(transformHalfwidth: true) {
                if let _ = types.filter({$0 == .Numeric}).first {
                    CFStringTransform(halfwidthChar, nil, kCFStringTransformFullwidthHalfwidth, reverse)
                    transformedChars.append(halfwidthChar as String)
                } else {
                    transformedChars.append($0)
                }
            }
            else if char.isEnglish(transformHalfwidth: true) {
                if let _ = types.filter({$0 == .English}).first {
                    CFStringTransform(halfwidthChar, nil, kCFStringTransformFullwidthHalfwidth, reverse)
                    transformedChars.append(halfwidthChar as String)
                } else {
                    transformedChars.append($0)
                }
            }
            else if char.isJapanese() {
                if let _ = types.filter({$0 == .Katakana}).first {
                    CFStringTransform(halfwidthChar, nil, kCFStringTransformFullwidthHalfwidth, reverse)
                    transformedChars.append(halfwidthChar as String)
                } else {
                    transformedChars.append($0)
                }
            }
            else {
                if let _ = types.filter({$0 == .Other}).first {
                    CFStringTransform(halfwidthChar, nil, kCFStringTransformFullwidthHalfwidth, reverse)
                    transformedChars.append(halfwidthChar as String)
                } else {
                    transformedChars.append($0)
                }
            }
        }
        
        var transformedString = ""
        transformedChars.forEach{ transformedString += $0 }
        
        return transformedString
    }

    func isNumber(transformHalfwidth transform :Bool) -> Bool {
        let halfwidthStr = NSMutableString(string: self) as CFMutableString
        CFStringTransform(halfwidthStr, nil, kCFStringTransformFullwidthHalfwidth, false)
        let str = halfwidthStr as String
     
        return Int(str) != nil ? true : false
    }

    func isEnglish(transformHalfwidth transform :Bool) -> Bool {
        let halfwidthStr = NSMutableString(string: self) as CFMutableString
        if transform {
            CFStringTransform(halfwidthStr, nil, kCFStringTransformFullwidthHalfwidth, false)
        }
        let str = halfwidthStr as String
        
        let pattern = "[A-z]*"
        do {
            let regex = try NSRegularExpression(pattern: pattern, options: .CaseInsensitive)
            let result = regex.stringByReplacingMatchesInString(str, options: [], range: NSMakeRange(0, str.characters.count), withTemplate: "")
            if result == "" { return true }
            else { return false }
        }
        catch { return false }
    }

    func isJapanese() -> Bool {
        let halfwidthStr = NSMutableString(string: self) as CFMutableString
        CFStringTransform(halfwidthStr, nil, kCFStringTransformFullwidthHalfwidth, true)
        let str = halfwidthStr as String
        
        let pattern = "^[\\u3041-\\u3093\\u30A1-\\u30F6\\u30FC]+$"
        do {           
            let regex = try NSRegularExpression(pattern: pattern, options: .CaseInsensitive)
            let result = regex.stringByReplacingMatchesInString(str, options: [], range: NSMakeRange(0, str.characters.count), withTemplate: "")
            if result == "" { return true }
            else { return false }
        }
        catch { return false }
    }

    func isKatakana() -> Bool {
        let halfwidthStr = NSMutableString(string: self) as CFMutableString
        CFStringTransform(halfwidthStr, nil, kCFStringTransformFullwidthHalfwidth, true)
        let str = halfwidthStr as String
        
        let pattern = "^[\\u30A0-\\u30FF]+$"
        do {           
            let regex = try NSRegularExpression(pattern: pattern, options: .CaseInsensitive)
            let result = regex.stringByReplacingMatchesInString(str, options: [], range: NSMakeRange(0, str.characters.count), withTemplate: "")
            if result == "" { return true }
            else { return false }
        }
        catch { return false }
    }
}