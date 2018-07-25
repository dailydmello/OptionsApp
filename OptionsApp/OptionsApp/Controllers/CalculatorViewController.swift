//
//  CalculatorViewController.swift
//  OptionsApp
//
//  Created by Ethan D'Mello on 2018-07-24.
//  Copyright © 2018 Ethan D'Mello. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import SwiftyJSON

class CalculatorViewController: UIViewController{
    
    
    @IBOutlet weak var symbolTextField: SymbolTextField!
    @IBOutlet weak var currentPriceLabel: UILabel!
    
    @IBOutlet weak var getPriceButton: UIButton!
    
    @IBOutlet weak var optionStrategySegmentedControl: UISegmentedControl!
    @IBOutlet weak var strikePriceTextField: UITextField!
    @IBOutlet weak var numofContractsTextField: UITextField!
    @IBOutlet weak var expiryDateTextField: UITextField!
    @IBOutlet weak var costLabel: UILabel!
    
    @IBOutlet weak var calculateCostButton: UIButton!
    
    @IBOutlet weak var graphButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        symbolTextField.calculateButtonAction = {
            guard let symbolText = self.symbolTextField.text
                else {return}
            print("the symbol is \(symbolText)")
            
            if self.symbolTextField.isFirstResponder {
                self.symbolTextField.resignFirstResponder()
            }
            print(self.symbolTextField.text)
            
            let apiToContact = "https://www.alphavantage.co/query?function=TIME_SERIES_INTRADAY&symbol=\(symbolText)&interval=1min&apikey=NXO7H3J2KOGFSKOI"
            
            Alamofire.request(apiToContact).validate().responseJSON() { response in
                var tempArr = [TimeSeriesIntraday]()
               
                switch response.result {
                case .success:
                    print ("API request was a success")
                    let result = response.result.value as! [String:Any]
                    //print(result)
                    
                    guard let dict = result["Time Series (1min)"] as? [String: Any] else{
                        print("Could not retrieve timestamps")
                        //completion([])
                        return
                    }
                    print(dict)
                    
                    for dic in dict{
                        guard let date = self.stringToDateAndTime(string: dic.key),
                            let tempValue = dic.value as? [String: Any] else {
                                //print("Could not retrieve Date and Time")
                                return
                        }
                        tempArr.append(TimeSeriesIntraday(dict: tempValue, timeStamp: date))
                    }
                    
                    let sortedData = TimeSeriesIntraday.sortSeriesByTime(array: tempArr)
                    //print(sortedData)
                    
                    //print(sortedData[sortedData.count-1].close)
                    guard let number = Double(sortedData[sortedData.count-1].close)
                        else {return}
                    
                    let roundedNumber = (100 * number).rounded()/100
                
                    self.currentPriceLabel.text = String(roundedNumber)

                    //completion[TimeSeriesIntraday.get]
                    
//                    if let value = response.result.value {
//
//                        let json = JSON(value)
//                        print(json)
//
//
//                        // Do what you need to with JSON here!
//                        // The rest is all boiler plate code you'll use for API requests
//
//
//                    }
                    
                    
                case .failure(let error):
                    print(error)
                }
            }
        }
        //print(self.symbolTextField.text)

    }
    
    @IBAction func getPriceButtonTapped(_ sender: UIButton) {
        print("get price button tapped")
    }
    
    @IBAction func strategySelected(_ sender: UISegmentedControl) {
    }
    
    
    @IBAction func calculateCostButtonTapped(_ sender: UIButton) {
        print("calculate cost button tapped")
    }
    @IBAction func graphButtonTapped(_ sender: Any) {
        print("graph button tapped")
    }
    
    
    
}

extension CalculatorViewController{
    
    func stringToDateAndTime(string: String) -> (Date?){
        let dateAndTimeFormatter = DateFormatter()
        dateAndTimeFormatter.dateFormat = "yyyy'-'MM'-'dd' 'HH':'mm':'ss"
        let dateAndTimeFormatted = dateAndTimeFormatter.date(from: string)
        return dateAndTimeFormatted
    }
}
