//
//  ViewController.swift
//  PhoneExtractor2
//
//  Created by Farhad Gatiyatov on 25.08.2020.
//  Copyright © 2020 Farhad Gatiyatov. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

class MainScreenVC: UIViewController {
    
    var file: URL?
    
    let chooseBtn = UIButton()
    let resultBtn = UIButton()
    
    let activity = NVActivityIndicatorView(frame: .zero, type: .ballGridPulse, color: .gray, padding: 7)
    var res: String?
    
    var state: State = .initial {
        didSet {
            switch state {
            case .initial:
                self.resultBtn.isEnabled = false
                self.chooseBtn.isEnabled = true
                self.activity.stopAnimating()
                self.activity.isHidden = true
                
            case .processing:
                self.resultBtn.isEnabled = false
                self.chooseBtn.isEnabled = false
                self.activity.startAnimating()
                self.activity.isHidden = false
                
            case .final:
                self.resultBtn.isEnabled = true
                self.chooseBtn.isEnabled = true
                self.activity.stopAnimating()
                self.activity.isHidden = true
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpUI()
    }
    
    @objc
    func chooseFile() {
        self.openDocuments()
    }
    
    //    if self.file != nil {
    //    self.shareResult(result:  self.res, sender)
    //    return
    //    }
    
    func processFile() {
        self.res = nil
        self.file = nil
        guard let url = self.file else { return }
        let detector = DataExtractor(url: url)
        
        var str = ""
        detector.getPhoneNumbers()?.forEach { str += "\($0)\n"}
        //        self.shareResult(result: str, sender)
        self.res = str
    }
    
    @objc func shareResult() {
        guard let res = self.res else { return }
        //        FileManager.default.createFile(atPath: Logger.logPath + "77", contents: nil, attributes: [:])
        //        try? DataMgr.user.settings.write(to: URL(fileURLWithPath: Logger.logPath + "77"), options: .atomic)
        
        //            let url = Bundle.main.appStoreReceiptURL
        let exportData = [ res ]
        let activityViewController = UIActivityViewController(activityItems: exportData, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView =  self.resultBtn// so that iPads won't crash
        activityViewController.popoverPresentationController?.sourceRect = self.resultBtn.bounds
        // present the view controller
        self.present(activityViewController, animated: true, completion: nil)
        
    }
}

import MobileCoreServices
extension MainScreenVC: UIDocumentPickerDelegate {
    func openDocuments() {
        let importMenu =  UIDocumentPickerViewController(documentTypes: [String(kUTTypePDF),
                                                                         String(kUTTypeGIF),
                                                                         String(kUTTypeMP3),
                                                                         String(kUTTypeRTF),
                                                                         String(kUTTypeJPEG),
                                                                         String(kUTTypeAudio),
                                                                         String(kUTTypeImage),
                                                                         String(kUTTypeMovie),
                                                                         String(kUTTypeItem),
                                                                         String(kUTTypeText)], in: .import)
        if #available(iOS 11.0, *) {
            importMenu.allowsMultipleSelection = false
        }
        
        importMenu.delegate = self
        importMenu.modalPresentationStyle = .formSheet
        
        self.present(importMenu, animated: true, completion: nil)
    }
    
    //  ----------------------
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
        self.file = url
        self.processFile()
    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        self.file = urls.first
        self.processFile()
    }
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        controller.dismiss(animated: true, completion: nil)
        print("cancelled")
    }
    
}
extension MainScreenVC {
    
    enum State {
        case initial, processing, final
    }
}
extension MainScreenVC {
    func setUpUI() {
        
        self.view.addSubview(self.chooseBtn)
        self.view.addSubview(self.resultBtn)
        self.view.addSubview(self.activity)
        
        self.chooseBtn.translatesAutoresizingMaskIntoConstraints = false
        self.resultBtn.translatesAutoresizingMaskIntoConstraints = false
        self.activity.translatesAutoresizingMaskIntoConstraints = false
        
        self.chooseBtn.setTitle("Choose file", for: .normal)
        self.resultBtn.setTitle("Share result", for: .normal)
        
        
        self.chooseBtn.centerYAnchor.constraint(equalTo: self.view.centerYAnchor, constant: -50).isActive = true
        self.chooseBtn.centerXAnchor.constraint(equalTo: self.view.centerXAnchor, constant: 0).isActive = true
        
        self.chooseBtn.heightAnchor.constraint(equalToConstant: 100).isActive = true
        self.chooseBtn.widthAnchor.constraint(equalTo: self.chooseBtn.heightAnchor, constant: 0).isActive = true
        
        
        self.resultBtn.centerYAnchor.constraint(equalTo: self.view.centerYAnchor, constant: 50).isActive = true
        self.resultBtn.centerXAnchor.constraint(equalTo: self.view.centerXAnchor, constant: 0).isActive = true
        
        self.resultBtn.heightAnchor.constraint(equalToConstant: 100).isActive = true
        self.resultBtn.widthAnchor.constraint(equalTo: self.resultBtn.heightAnchor, constant: 0).isActive = true
        
        
        self.activity.centerYAnchor.constraint(equalTo: self.view.centerYAnchor, constant: 0).isActive = true
        self.activity.centerXAnchor.constraint(equalTo: self.view.centerXAnchor, constant: 0).isActive = true
        
        self.activity.heightAnchor.constraint(equalToConstant: 50).isActive = true
        self.activity.widthAnchor.constraint(equalTo: self.resultBtn.heightAnchor, constant: 0).isActive = true
        
        
        self.chooseBtn.addTarget(self, action: #selector(self.chooseFile), for: .touchUpInside)
    }
}

