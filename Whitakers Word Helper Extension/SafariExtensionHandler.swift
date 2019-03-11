//
//  SafariExtensionHandler.swift
//  Whitakers Word Helper Extension
//
//  Created by Max Sonderegger on 2/14/19.
//  Copyright © 2019 Max Sonderegger. All rights reserved.
//

import SafariServices

class SafariExtensionHandler: SFSafariExtensionHandler {
    
    override func messageReceived(withName messageName: String, from page: SFSafariPage, userInfo: [String : Any]?) {
        // This method will be called when a content script provided by your extension calls safari.extension.dispatchMessage("message").
        doDefinitions(withQuery: messageName, from: page, userInfo: userInfo)
    }
    
    override func contextMenuItemSelected(withCommand command: String, in page: SFSafariPage, userInfo: [String : Any]? = nil) {
        switch command {
        case "searchRequest":
            doDefinitions(withQuery: userInfo!["selectedText"] as! String, from: page, userInfo: userInfo)
        default:
            return
        }
    }
    
    override func toolbarItemClicked(in window: SFSafariWindow) {
        // This method will be called when your toolbar item is clicked.
        NSLog("The extension's toolbar item was clicked")
    }
    
    override func validateToolbarItem(in window: SFSafariWindow, validationHandler: @escaping ((Bool, String) -> Void)) {
        // This is called when Safari's state changed in some way that would require the extension's toolbar item to be validated again.
        validationHandler(true, "")
    }
    
    override func popoverViewController() -> SFSafariExtensionViewController {
        return SafariExtensionViewController.shared
    }
    
    func doDefinitions(withQuery queryString: String, from page: SFSafariPage, userInfo: [String : Any]?) {
        var formattedText = queryString.replacingOccurrences(of: "ā", with: "a")
        formattedText = formattedText.replacingOccurrences(of: "ē", with: "e")
        formattedText = formattedText.replacingOccurrences(of: "ī", with: "i")
        formattedText = formattedText.replacingOccurrences(of: "ō", with: "o")
        formattedText = formattedText.replacingOccurrences(of: "ū", with: "u")
        formattedText = formattedText.replacingOccurrences(of: "Ā", with: "A")
        formattedText = formattedText.replacingOccurrences(of: "Ē", with: "E")
        formattedText = formattedText.replacingOccurrences(of: "Ī", with: "I")
        formattedText = formattedText.replacingOccurrences(of: "Ō", with: "O")
        formattedText = formattedText.replacingOccurrences(of: "Ū", with: "U")
        formattedText = formattedText.replacingOccurrences(of: " ", with: "+")
        
        let numberOfWords = formattedText.split(separator: "+").count
        if numberOfWords == 2 {
            formattedText += "+et"
        }
        
        let url = URL(string: "http://www.archives.nd.edu/cgi-bin/wordz.pl?keyword=\(formattedText)")!
        let urlSession = URLSession.shared
        
        let getRequest = URLRequest(url: url)
        
        let task = urlSession.dataTask(with: getRequest as URLRequest, completionHandler: { data, response, error in
            
            guard error == nil else {
                page.dispatchMessageToScript(withName: "queryResponse", userInfo: ["responseText" : error!.localizedDescription])
                return
            }
            
            guard let data = data else {
                page.dispatchMessageToScript(withName: "queryResponse", userInfo: ["responseText" : "Error looking up data\nError code: \(WhitakersWordsHelperErrors.dataNotReturned.rawValue)"])
                return
            }
            // the data is returned in JSON format and needs to be converted into something that swift can work with
            // we are converting it into a dictionary of type [String: Any]
            guard let responseText = String(bytes: data, encoding: .utf8) else {
                page.dispatchMessageToScript(withName: "queryResponse", userInfo: ["responseText" : "Error decoding URL response\nError code: \(WhitakersWordsHelperErrors.cannotDecodeData.rawValue)"])
                return
            }
            let firstTagIndex = responseText.range(of: "<pre>")?.upperBound
            let lastTagIndex = responseText.range(of: "</pre>")?.lowerBound
            var selectedText = String(responseText[firstTagIndex!..<lastTagIndex!])
            if selectedText.isEmpty {
                page.dispatchMessageToScript(withName: "queryResponse", userInfo: ["responseText" : "Error parsing URL response\nError code: \(WhitakersWordsHelperErrors.parsingFailed.rawValue)"])
                return
            }
            if numberOfWords == 2 {
                var splitText = selectedText.split(separator: "\n", maxSplits: Int.max, omittingEmptySubsequences: false)
                splitText.removeSubrange((splitText.count - 6)..<splitText.count - 2)
                selectedText = splitText.joined(separator: "\n")
            }
            page.dispatchMessageToScript(withName: "queryResponse", userInfo: ["responseText" : selectedText])
        })
        
        task.resume()
    }

}

enum WhitakersWordsHelperErrors: Int {
    case dataNotReturned
    case cannotDecodeData
    case parsingFailed
}
