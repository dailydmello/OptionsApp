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

protocol CalculatorViewControllerDelegate {
    
    func passData() -> ([Double],String)
}

class CalculatorViewController: UIViewController, CalculatorViewControllerDelegate{
    
    
    

    @IBOutlet weak var underlyingTickerTextField: SymbolTextField!
    
    @IBOutlet weak var underlyingPriceLabel: UILabel!
    @IBOutlet weak var getPriceButton: UIButton!

    @IBOutlet weak var callPriceTextField: SymbolTextField!
    @IBOutlet weak var strikePriceTextField: SymbolTextField!
    @IBOutlet weak var numofContractsTextField: SymbolTextField!
    @IBOutlet weak var expiryDateTextField: SymbolTextField!
    @IBOutlet weak var costLabel: UILabel!
    
    @IBOutlet weak var calculateCostButton: UIButton!
    @IBOutlet weak var graphButton: UIButton!
    
    //var delegate: ProfitGraphViewControllerDelegate?
    
    var calculation: Calculation?
    var tempArr = [Double]()
    var underlyingTicker: String = ""
    var underlyingPrice: Double = 0
    var priceOfCall: Double = 0
    var strikePrice: Double = 0
    var numOfOptions: Double = 0
    
    func passData()-> ([Double],String){
        tempArr.append(self.underlyingPrice)
        tempArr.append(self.priceOfCall)
        tempArr.append(self.strikePrice)
        tempArr.append(self.numOfOptions)
        return (tempArr,self.underlyingTicker)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        //code enter underlying stock ticker, hit enter, and retrieve latest ticker stock price
        //Check tomorrow
//        if let delegate = delegate {
//            print("Hello World")
//            [underlyingPrice,priceOfCall,strikePrice,numOfOptions]
//            let newData = delegate.passDataToCalculator()
//            print(newData.1)
//            underlyingTickerTextField.text = newData.1
//            underlyingPriceLabel.text = String((100 * Double(newData.0[0])).rounded()/100)
//            callPriceTextField.text = String(newData.0[1])
//            strikePriceTextField.text = String(newData.0[2])
//            numofContractsTextField.text = String(newData.0[3]/100)
//        }
        //underlyingTicker = newData.1

        
        
        underlyingTickerTextField.calculateButtonAction = {
            self.getSymbolCurrentPrice(){ stockPrice in
                
                self.underlyingPrice = stockPrice
                
                if let underlyingTickerText = self.underlyingTickerTextField.text{
                    self.underlyingTicker = underlyingTickerText
                }
                
                //print("yousuck")
                print(self.underlyingPrice)
            }
        }
        
        callPriceTextField.calculateButtonAction = {
            if self.callPriceTextField.isFirstResponder {
                self.callPriceTextField.resignFirstResponder()
            }
            if let callPriceText = self.callPriceTextField.text, let callPriceFloat = Double(callPriceText){
                self.priceOfCall = callPriceFloat
            }
            print(self.priceOfCall)
        }
        
        strikePriceTextField.calculateButtonAction = {
            if self.strikePriceTextField.isFirstResponder {
                self.strikePriceTextField.resignFirstResponder()
            }
            if let strikePriceText = self.strikePriceTextField.text, let strikePriceFloat = Double(strikePriceText){
                self.strikePrice = strikePriceFloat
            }
            
        }
        numofContractsTextField.calculateButtonAction = {
            if self.numofContractsTextField.isFirstResponder {
                self.numofContractsTextField.resignFirstResponder()
            }
            if let numOfContractsText = self.numofContractsTextField.text, let numOfContractsFloat = Double(numOfContractsText) {self.numOfOptions = numOfContractsFloat * 100}
        }
        expiryDateTextField.calculateButtonAction = {
            if self.expiryDateTextField.isFirstResponder {
                self.expiryDateTextField.resignFirstResponder()
            }
        }

    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
//        underlyingTickerTextField.text = underlyingTicker
//        underlyingPriceLabel.text = String((100 * underlyingPrice).rounded()/100)
        
       
        
        if let calculation = calculation {
            underlyingTickerTextField.text = calculation.underlyingTicker
            underlyingPriceLabel.text = calculation.underlyingPrice
            callPriceTextField.text = calculation.callPrice
            strikePriceTextField.text = calculation.strikePrice
            numofContractsTextField.text = calculation.numOfContracts
            expiryDateTextField.text = ""
        } else {
        underlyingTickerTextField.text = ""
        underlyingPriceLabel.text = ""
        callPriceTextField.text = ""
        strikePriceTextField.text = ""
        numofContractsTextField.text = ""
        expiryDateTextField.text = ""
        //Before all text was set to ""
        }
    }

    @IBAction func strategyChanged(_ sender: UISegmentedControl) {
    }
    @IBAction func calculateCostButtonTapped(_ sender: UIButton) {
        calculateCallTotalCost()
    }
    @IBAction func graphButtonTapped(_ sender: Any) {
        self.performSegue(withIdentifier: "graph", sender: nil)
        self.updateCalculation()
        CoreDataHelper.saveUniqueCalculation(calculation: calculation!)
    }
    
    @IBAction func unwindWithSegue(_ segue: UIStoryboardSegue) {
        if segue.identifier == "back"{
            upDateView()
        }
    }
    
    func updateCalculation(){
         calculation = CoreDataHelper.newCalculation()
        calculation?.strategyTitle = "Long Call"
        calculation?.underlyingTicker = underlyingTickerTextField.text ?? ""
        calculation?.underlyingPrice = underlyingPriceLabel.text ?? ""
        calculation?.callPrice = callPriceTextField.text ?? ""
        calculation?.strikePrice = strikePriceTextField.text ?? ""
        calculation?.numOfContracts = numofContractsTextField.text ?? ""
        calculation?.modificationTime = Date()
    }
    
    func upDateView(){
        
         calculation = CoreDataHelper.retrieveLastCalculation()
        
        underlyingTickerTextField.text = calculation?.underlyingTicker
        underlyingPriceLabel.text = calculation?.underlyingPrice
        callPriceTextField.text = calculation?.callPrice
        strikePriceTextField.text = calculation?.strikePrice
        numofContractsTextField.text = calculation?.numOfContracts
        expiryDateTextField.text = ""
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier else { return }
        
        switch identifier { //here is the problem
        case "graph":
            //if destination is profitgraph, cast profit as profitgrapgviewcontroller
            if let profitGraphViewController = segue.destination as? ProfitGraphViewController{
                profitGraphViewController.delegate = self}
 
        case "save" where calculation != nil: //when it is not a new
                self.updateCalculation()
                
                
                 CoreDataHelper.saveCalculation()
            
                //in order to access the destination view controller's properties, we need to type cast the destination view controller to type ListCalculationsTableViewController
            
            
        case "save" where calculation == nil: //new calculation:
            
             self.updateCalculation()
            
            CoreDataHelper.saveCalculation()

        case "cancel":
                print("cancel button tapped")
                    
        default:
                print("unexpected segue")
        
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
        let totalCallCost = Float(callPrice)! * totalnumOfCallOptions
        self.costLabel.text = String(totalCallCost)
    }
    
    func getSymbolCurrentPrice(completion: @escaping (_: Double) -> ()){
        
        //code enter underlying stock ticker, hit enter, and retrieve latest ticker stock price
            guard let symbolText = self.underlyingTickerTextField.text
                else {return}
            if self.underlyingTickerTextField.isFirstResponder {
                self.underlyingTickerTextField.resignFirstResponder()
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
                    guard let latestTickerStockPrice = Double(sortedData[sortedData.count-1].close)
                        else {return}
                    let stockPriceRounded = (100 * latestTickerStockPrice).rounded()/100
                    self.underlyingPriceLabel.text = String(stockPriceRounded)
//                    print(Float(stockPriceRounded))
//                    print(Double(stockPriceRounded))
                    completion(Double(stockPriceRounded))
                case .failure(let error):
                    print ("API request did not succeed")
                    print(error)
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
