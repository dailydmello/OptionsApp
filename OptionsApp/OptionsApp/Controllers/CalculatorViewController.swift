//
//  CalculatorViewController.swift
//  OptionsApp
//
//  Created by Ethan D'Mello on 2018-07-24.
//  Copyright © 2018 Ethan D'Mello. All rights reserved.
//

import Foundation
import UIKit

class CalculatorViewController: UIViewController{
    
    
    @IBOutlet weak var symbolTextField: UITextField!
    @IBOutlet weak var currentPriceLabel: UILabel!
    
    @IBOutlet weak var getPriceButton: UIButton!
    
    @IBOutlet weak var optionStrategySegmentedControl: UISegmentedControl!
    @IBOutlet weak var strikePriceTextField: UITextField!
    @IBOutlet weak var numofContractsTextField: UITextField!
    @IBOutlet weak var expiryDateTextField: UITextField!
    @IBOutlet weak var costLabel: UILabel!
    
    @IBOutlet weak var graphButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func getPriceButtonTapped(_ sender: UIButton) {
        print("get price button tapped")
    }
    
    @IBAction func strategySelected(_ sender: UISegmentedControl) {
    }
    
    @IBAction func graphButtonTapped(_ sender: Any) {
        print("graph button tapped")
    }
    
}
