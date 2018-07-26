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
    @IBOutlet weak var strikePriceTextField: SymbolTextField!
    @IBOutlet weak var numofContractsTextField: SymbolTextField!
    @IBOutlet weak var expiryDateTextField: SymbolTextField!
    @IBOutlet weak var costLabel: UILabel!
    
    @IBOutlet weak var calculateCostButton: UIButton!
    @IBOutlet weak var graphButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //code enter underlying stock ticker, hit enter, and retrieve latest ticker stock price
        symbolTextField.calculateButtonAction = {
            guard let symbolText = self.symbolTextField.text
                else {return}
            if self.symbolTextField.isFirstResponder {
                self.symbolTextField.resignFirstResponder()
            }
            //print(self.symbolTextField.text)
            let apiToContact = "https://www.alphavantage.co/query?function=TIME_SERIES_INTRADAY&symbol=\(symbolText)&interval=1min&apikey=NXO7H3J2KOGFSKOI"
            Alamofire.request(apiToContact).validate().responseJSON() { response in
                var tempArr = [TimeSeriesIntraday]()
                switch response.result {
                    case .success:
                        print ("API request was a success")
                        //Get data ready to store in custom array of dictionaries
                        let result = response.result.value as! [String:Any]
                        guard let dict = result["Time Series (1min)"] as? [String: Any] else{
                            print("Could not retrieve timestamps")
                            //completion([])
                            return
                        }
                        //Format timestamp to proper date format
                        for dic in dict{
                            guard let date = self.stringToDateAndTime(string: dic.key),
                                let tempValue = dic.value as? [String: Any] else {
                                    return
                            }
                        //populate new array of TimeSeriestIntraday objects, 100 objects created 1 min apart
                            tempArr.append(TimeSeriesIntraday(dict: tempValue, timeStamp: date))
                        }
                        //sort the array from oldest to newest data
                        let sortedData = TimeSeriesIntraday.sortSeriesByTime(array: tempArr)
                        guard let lastestTickerStockPrice = Double(sortedData[sortedData.count-1].close)
                            else {return}
                        let stockPriceRounded = (100 * lastestTickerStockPrice).rounded()/100
                        self.currentPriceLabel.text = String(stockPriceRounded)
                    case .failure(let error):
                        print ("API request did not succeed")
                        print(error)
                }
            }
        }
        strikePriceTextField.calculateButtonAction = {
            guard let priceText = self.strikePriceTextField.text
                else {return}
            print(priceText)
            if self.strikePriceTextField.isFirstResponder {
                self.strikePriceTextField.resignFirstResponder()
            }
        }
        numofContractsTextField.calculateButtonAction = {
            guard let numofContractsText = self.numofContractsTextField.text
                else {return}
            print(numofContractsText)
            if self.numofContractsTextField.isFirstResponder {
                self.numofContractsTextField.resignFirstResponder()
            }
        }
        expiryDateTextField.calculateButtonAction = {
            guard let expiryDateText = self.expiryDateTextField.text
                else {return}
            print(expiryDateText)
            if self.expiryDateTextField.isFirstResponder {
                self.expiryDateTextField.resignFirstResponder()
            }
        }
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
