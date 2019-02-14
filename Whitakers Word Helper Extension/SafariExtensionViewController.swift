//
//  SafariExtensionViewController.swift
//  Whitakers Word Helper Extension
//
//  Created by Max Sonderegger on 2/14/19.
//  Copyright © 2019 Max Sonderegger. All rights reserved.
//

import SafariServices

class SafariExtensionViewController: SFSafariExtensionViewController {
    
    static let shared: SafariExtensionViewController = {
        let shared = SafariExtensionViewController()
        shared.preferredContentSize = NSSize(width:320, height:240)
        return shared
    }()

}
