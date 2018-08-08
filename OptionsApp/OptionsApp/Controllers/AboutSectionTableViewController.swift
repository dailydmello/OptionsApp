//
//  AboutSectionTableViewController.swift
//  OptionsApp
//
//  Created by Ethan D'Mello on 2018-08-06.
//  Copyright © 2018 Ethan D'Mello. All rights reserved.
//

import Foundation
import UIKit

class AboutSectionTableViewController: UIViewController{
    
    @IBOutlet weak var backBarButtonItem: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        backBarButtonItem.setTitleTextAttributes([
            NSAttributedStringKey.font: UIFont(name: "ProximaNova-Light", size: 18.0)!,
            NSAttributedStringKey.foregroundColor: UIColor.tcWhite],
                                                   for: .normal)
        
    }
}
