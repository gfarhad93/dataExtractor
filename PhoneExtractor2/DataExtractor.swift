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
    
    class PendingOperations {
        lazy var downloadsInProgress = [NSIndexPath:Operation]()
        lazy var downloadQueue:OperationQueue = {
            var queue = OperationQueue()
            queue.name = "Phone queue"
            queue.maxConcurrentOperationCount = 10
            return queue
        }()
        
        lazy var filtrationsInProgress = [NSIndexPath:Operation]()
        lazy var filtrationQueue:OperationQueue = {
            var queue = OperationQueue()
            queue.name = "Email queue"
            queue.maxConcurrentOperationCount = 10
            return queue
        }()
    }
    
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
    
    func processEmails(from text: String?) -> [String]? {
        guard let text = text else { return nil }
        
        let strings1 = text.split(separator: "\n").map { String($0) }
        let strings5 = text.split(separator: " ").map { String($0) }
        
        let allStrings = Array(Set(strings1 + strings5))
                
        var arr = Set<String>()
        let pattern = "(?:[\\p{L}0-9!#$%\\&'*+/=?\\^_`{|}~-]+(?:\\.[\\p{L}0-9!#$%\\&'*+/=?\\^_`{|}" +
                           "~-]+)*|\"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\" +
                           "x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*\")@(?:(?:[\\p{L}0-9](?:[a-" +
                           "z0-9-]*[\\p{L}0-9])?\\.)+[\\p{L}0-9](?:[\\p{L}0-9-]*[\\p{L}0-9])?|\\[(?:(?:25[0-5" +
                           "]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-" +
                           "9][0-9]?|[\\p{L}0-9-]*[\\p{L}0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21" +
                           "-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\])"

        do {
            let regex = try NSRegularExpression(pattern: pattern, options: [])
            
            var inMatches = [NSTextCheckingResult]()
            for str in allStrings {
                                
                let matches = regex.matches(in: str, range: NSRange(str.startIndex..., in: str))
                for match in matches {
                    if let range = Range(match.range, in: str) {
                        let matchString = String(str[range])
                        arr.insert(matchString)
                    }
                }
                inMatches.append(contentsOf: matches)
            }
            
            print(inMatches.count)
                        
        } catch {
            print(error)
        }
        
        return Array(arr)

    }
   
    func processNumbers(from text: String?) -> [String]? {
        guard let text = text else { return nil }
        
        let strings1 = text.split(separator: "\n").map { String($0) }
        let strings2 = text.split(separator: "+").map { String($0) }
        let strings3 = text.split(separator: "7").map { String($0) }
        let strings4 = text.split(separator: "8").map { String($0) }
        let strings5 = text.split(separator: " ").map { String($0) }

        let allStrings = Array(Set(strings1 + strings2 + strings3 + strings4 + strings5))
        
        let phones = self.phoneKit.parse(allStrings)
        
        var arr = Set<String>()

        do {
            let detector = try NSDataDetector(types: NSTextCheckingResult.CheckingType.phoneNumber.rawValue)

            var inMatches = [NSTextCheckingResult]()
            for str in allStrings {


                let matches = detector.matches(in: str, range: NSRange(str.startIndex..., in: str))

                inMatches.append(contentsOf: matches)
            }
            
            print(inMatches.count)
                        
            let matches = detector.matches(in: text, range: NSRange(text.startIndex..., in: text))
            print(matches.count)
            
            let matchesAll = Set(matches + inMatches)
            
            for match in matchesAll {
                if match.resultType == .phoneNumber, let number = match.phoneNumber {
                    do {
                        let phone = try self.phoneKit.parse(number)
                        arr.insert(self.phoneKit.format(phone, toType: .international))
                    } catch {
//                        print(error)
                    }
                }
            }

            for phone in phones {
                do {
                    arr.insert(self.phoneKit.format(phone, toType: .international))
                } catch {
                    print(error)
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
    
    func getEmails() -> [String]? {
        guard let text = self.textFromUrl() else { return nil }
        guard let mails = self.processEmails(from: text) else { return nil }
        
        return mails
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

extension NSRegularExpression {
    func matches(_ string: String) -> Bool {
        let range = NSRange(location: 0, length: string.utf16.count)
        return firstMatch(in: string, options: [], range: range) != nil
    }
}
