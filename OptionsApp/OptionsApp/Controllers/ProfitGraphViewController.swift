//
//  ProfitGraphViewController.swift
//  OptionsApp
//
//  Created by Ethan D'Mello on 2018-07-24.
//  Copyright © 2018 Ethan D'Mello. All rights reserved.
//

import Foundation
import UIKit
import Charts


class ProfitGraphViewController: UIViewController{
    
    var newData = [Float]()
    
    var delegate: CalculatorViewControllerDelegate?
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        if let delegate = delegate {
            //[underlyingPrice,priceOfCall,strikePrice,numOfOptions]
            newData = delegate.passData()
        }
        print(newData)
        
    }
}




