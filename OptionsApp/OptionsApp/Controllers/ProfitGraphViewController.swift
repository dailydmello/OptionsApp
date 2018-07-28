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


class ProfitGraphViewController: UIViewController, ClassCalculatorViewControllerDelegate{

    

    var x:Double = 0
    @IBOutlet weak var testButton: UIButton!
    
    override func viewDidLoad() {
    super.viewDidLoad()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let nav = segue.destination as? UINavigationController, let calculatorViewController = nav.topViewController as? CalculatorViewController{
            calculatorViewController.delegate = self
        }
    }
    func graphValues(numOfOptions: Float, callPrice: Float, underlyingPrice: Float, strikePrice: Float) -> Float {
        return numOfOptions
    }
}




