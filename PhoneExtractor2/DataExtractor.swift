//
//  DataExtractor.swift
//  PhoneExtractor2
//
//  Created by Farhad Gatiyatov on 25.08.2020.
//  Copyright © 2020 Farhad Gatiyatov. All rights reserved.
//

import Foundation
import PhoneNumberKit

class DataExtractor {
    
    var url: URL?
    fileprivate let phoneKit = PhoneNumberKit.init()
    
    init(url: URL) {
        self.url = url
    }
    
    func textFromUrl() -> String? {
        guard let url = self.url else { return nil }
        var result: String?

        switch url.pathExtension.lowercased() {
        case "docx":
            result = self.textFromWord()
        default:
           break
        }
        
        return result
    }
    
   
    func processNumbers(from text: String?) -> [String]? {
        guard let text = text else { return nil }
        
        var arr = Set<String>()
        
        do {
            let detector = try NSDataDetector(types: NSTextCheckingResult.CheckingType.phoneNumber.rawValue)
            
            let matches = detector.matches(in: text, range: NSRange(text.startIndex..., in: text))
            
            for match in matches{
                if match.resultType == .phoneNumber, let number = match.phoneNumber {
                    do {
                        let phone = try self.phoneKit.parse(number)
                        arr.insert(self.phoneKit.format(phone, toType: .international))
                    } catch {
                        print(error)
                    }
                }
            }
        } catch {
            print( error )
        }
        
        return Array(arr)
    }
    
    func getPhoneNumbers() -> [String]? {
        guard let text = self.textFromUrl() else { return nil }
        guard let nums = self.processNumbers(from: text) else { return nil }
        
        return nums
    }
    
    func tempUnzipPath() -> String? {
        var path = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)[0]
        path += "/\(UUID().uuidString)"
        let url = URL(fileURLWithPath: path)

        do {
            try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
        } catch {
            return nil
        }
        return url.path
    }
}
