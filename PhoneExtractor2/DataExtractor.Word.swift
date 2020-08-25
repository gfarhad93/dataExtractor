//
//  DataExtractor.Word.swift
//  PhoneExtractor2
//
//  Created by Farhad Gatiyatov on 25.08.2020.
//  Copyright © 2020 Farhad Gatiyatov. All rights reserved.
//

import SSZipArchive

extension DataExtractor {
    func textFromWord() -> String? {
        guard let zipPath = self.url?.path else { return nil }
        
        guard let unzipPath = tempUnzipPath() else { return nil }
        print("Unzip path:", unzipPath)
        
        let password = "" //for future
        let success: Bool = SSZipArchive.unzipFile(atPath: zipPath,
                                                   toDestination: unzipPath,
                                                   preserveAttributes: true,
                                                   overwrite: true,
                                                   nestedZipLevel: 1,
                                                   password: !password.isEmpty ? password : nil,
                                                   error: nil,
                                                   delegate: nil,
                                                   progressHandler: nil,
                                                   completionHandler: nil)
        if success != false {
            print("Success unzip")
        } else {
            print("No success unzip")
            return nil
        }
        
        guard let resArr = self.find(name: "document.xml", in: unzipPath), let url = resArr.first else { return nil }
        var result: String?
        do {
            let data = try Data(contentsOf: url)
            result =  parseDocx(data)
        } catch {
            print(error)
        }
        
        return result
    }
    
    func find(name: String, in directory: String) -> [URL]? {
        let url = URL(fileURLWithPath: directory)
        var files = [URL]()

        if let enumerator = FileManager.default.enumerator(at: url, includingPropertiesForKeys: [.isRegularFileKey], options: [.skipsHiddenFiles, .skipsPackageDescendants]) {
            for case let fileURL as URL in enumerator {
                do {
                    let fileAttributes = try fileURL.resourceValues(forKeys:[.isRegularFileKey])
                    if fileAttributes.isRegularFile! {
                        files.append(fileURL)
                    }
                } catch { print(error, fileURL) }
            }
            print(files)
        }
        
        
        let rr = files.compactMap { (url) -> URL? in
            guard url.pathComponents.contains(name) else { return nil }
            return url
        }
     
        return rr
    }
    
    private func parseDocx(_ data:Data?)->String?{
        guard let data = data else {
            return nil
        }
        let str = String.init(data: data, encoding: .utf8)
        
        return matches(str ?? "")
    }
    
    
    private func matches(_ originalText:String)->String{
        var result = [String]()
        var re: NSRegularExpression!
        do {
            re = try NSRegularExpression(pattern: "<w:t.*?>(.*?)<\\/w:t>", options: [])
        } catch {
            
        }
        
        let matches = re.matches(in: originalText, options: [], range: NSRange(location: 0, length: originalText.utf16.count))
        
        for match in matches {
            
            result.append((originalText as NSString).substring(with: match.range(at: 1)))
        }
        return result.joined(separator: "\n")
    }
    
}
