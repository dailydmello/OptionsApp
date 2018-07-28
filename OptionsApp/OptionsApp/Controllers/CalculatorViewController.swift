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

protocol ClassCalculatorViewControllerDelegate: class {
    func graphValues(numOfOptions: Float, callPrice: Float, underlyingPrice: Float, strikePrice: Float) -> Float
}

class CalculatorViewController: UIViewController{
    
    
    @IBOutlet weak var symbolTextField: SymbolTextField!
    @IBOutlet weak var currentPriceLabel: UILabel!
    
    @IBOutlet weak var getPriceButton: UIButton!

    @IBOutlet weak var callPriceTextField: SymbolTextField!
    @IBOutlet weak var strikePriceTextField: SymbolTextField!
    @IBOutlet weak var numofContractsTextField: SymbolTextField!
    @IBOutlet weak var expiryDateTextField: SymbolTextField!
    @IBOutlet weak var costLabel: UILabel!
    
    @IBOutlet weak var calculateCostButton: UIButton!
    @IBOutlet weak var graphButton: UIButton!
    
    weak var delegate: ClassCalculatorViewControllerDelegate?
    var numOfOptions: Float?
    var callPrice: Float?
    var underlyingPrice: Float?
    var strikePrice: Float?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //code enter underlying stock ticker, hit enter, and retrieve latest ticker stock price
        symbolTextField.calculateButtonAction = {
            self.getSymbolCurrentPrice()
        }
        guard let numberText = currentPriceLabel.text,
            let underlyingPrice = Float(numberText) else {
                return
            }
        //print(under)
        callPriceTextField.calculateButtonAction = {
            if self.callPriceTextField.isFirstResponder {
                self.callPriceTextField.resignFirstResponder()
            }
        }
        if let number = callPriceTextField.text{
            callPrice = Float(number)
        }else{return}
        //////////////////////////////////////
        strikePriceTextField.calculateButtonAction = {
            if self.strikePriceTextField.isFirstResponder {
                self.strikePriceTextField.resignFirstResponder()
            }
        }
        if let number = strikePriceTextField.text{
            strikePrice = Float(number)
        }else{return}
        //////////////////////////////////////////
        numofContractsTextField.calculateButtonAction = {
            if self.numofContractsTextField.isFirstResponder {
                self.numofContractsTextField.resignFirstResponder()
            }
        }
        if let number = numofContractsTextField.text{
            numOfOptions = Float(number)
        }else{return}
        //////////////////////////////////////
        expiryDateTextField.calculateButtonAction = {
            if self.expiryDateTextField.isFirstResponder {
                self.expiryDateTextField.resignFirstResponder()
            }
        }

    }
    @IBAction func getPriceButtonTapped(_ sender: UIButton) {
        print("get price button tapped")
    }

    @IBAction func calculateCostButtonTapped(_ sender: UIButton) {
        calculateCallTotalCost()
    }
    @IBAction func graphButtonTapped(_ sender: Any) {
        print("graph button tapped")
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // 1
        guard let identifier = segue.identifier else { return }
        
        // 2
        if identifier == "displayGraph" {
            print("Transitioning to the Graph View Controller")
            print(numOfOptions!)
            
            delegate?.graphValues(numOfOptions: numOfOptions!, callPrice: callPrice!, underlyingPrice: underlyingPrice!, strikePrice: strikePrice!)
            
           
        }
    }

}

extension CalculatorViewController{
    
    func calculateCallTotalCost(){
        guard let callPrice = self.callPriceTextField.text
            else {return}
        guard let numOfContracts = self.numofContractsTextField.text
        else{return}
        let totalnumOfCallOptions = Float(numOfContracts)! * 100
        let entryCost = Float(callPrice)! * totalnumOfCallOptions
        self.costLabel.text = String(entryCost)
    }
    
    func getSymbolCurrentPrice(){
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
                    guard let latestTickerStockPrice = Float(sortedData[sortedData.count-1].close)
                        else {return}
                    let stockPriceRounded = (100 * latestTickerStockPrice).rounded()/100
                    self.currentPriceLabel.text = String(stockPriceRounded)
                case .failure(let error):
                    print ("API request did not succeed")
                    print(error)
                }
            }
        }
    }
        
    func stringToDateAndTime(string: String) -> (Date?){
        let dateAndTimeFormatter = DateFormatter()
        dateAndTimeFormatter.dateFormat = "yyyy'-'MM'-'dd' 'HH':'mm':'ss"
        let dateAndTimeFormatted = dateAndTimeFormatter.date(from: string)
        return dateAndTimeFormatted
    }
    
    
}
