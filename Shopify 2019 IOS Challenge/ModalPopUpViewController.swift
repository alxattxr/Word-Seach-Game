//
//  ModalPopUpViewController.swift
//  Shopify 2019 IOS Challenge
//
//  Created by Alexandre Attar on 2019-05-15.
//  Copyright © 2019 AADevelopment. All rights reserved.
//

import UIKit

class ModalPopUpViewController: UIViewController {

    @IBAction func goToHomePage(_ sender: Any) {
        self.view.window!.rootViewController?.dismiss(animated: false, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

}
