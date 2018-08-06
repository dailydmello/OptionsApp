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

class CalculatorViewController: UIViewController, CalculatorViewControllerDelegate,UITextFieldDelegate{
    
    @IBOutlet weak var underlyingTickerTextField: UITextField!
    
    @IBOutlet weak var underlyingPriceLabel: UILabel!
    @IBOutlet weak var getPriceButton: UIButton!
    
    @IBOutlet weak var StrategyTitleLabel: UILabel!
    @IBOutlet weak var callPriceTextField: SymbolTextField!
    @IBOutlet weak var strikePriceTextField: SymbolTextField!
    @IBOutlet weak var numofContractsTextField: SymbolTextField!
    @IBOutlet weak var expiryDateTextField: UITextField!
    @IBOutlet weak var costLabel: UILabel!
    
    @IBOutlet weak var callAndPutLabel: UILabel!
    @IBOutlet weak var calculateCostButton: UIButton!
    @IBOutlet weak var graphButton: UIButton!
    @IBOutlet weak var callOrPutSegmentedControl: UISegmentedControl!
    
    //buy or sell
    
    @IBOutlet weak var buyOrSellSegmentedControl: UISegmentedControl!
    var calculation: Calculation?
    var tempArr = [Double]()
    var underlyingTicker: String = ""
    var underlyingPrice: Double = 0
    var callPrice: Double = 0
    var strikePrice: Double = 0
    var numOfOptions: Double = 0
    var strategy: Double = 0
    var expiryDate: String = ""
    var buyOrSellChoice: Double = 0
    var callOrPutChoice: Double = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        underlyingTickerTextField.delegate = self
        expiryDateTextField.delegate = self
        
        callPriceTextField.calculateButtonAction = {
            if self.callPriceTextField.isFirstResponder {
                self.callPriceTextField.resignFirstResponder()
            }
            if let callPriceText = self.callPriceTextField.text, let callPriceDouble = Double(callPriceText){
                self.callPrice = callPriceDouble
            }
        }
        strikePriceTextField.calculateButtonAction = {
            if self.strikePriceTextField.isFirstResponder {
                self.strikePriceTextField.resignFirstResponder()
            }
            if let strikePriceText = self.strikePriceTextField.text, let strikePriceDouble = Double(strikePriceText){
                self.strikePrice = strikePriceDouble
            }
            
        }
        numofContractsTextField.calculateButtonAction = {
            if self.numofContractsTextField.isFirstResponder {
                self.numofContractsTextField.resignFirstResponder()
            }
            if let numOfContractsText = self.numofContractsTextField.text, let numOfContractsDouble = Double(numOfContractsText) {self.numOfOptions = numOfContractsDouble * 100
            }
        }

        if let calculation = calculation {
            underlyingTickerTextField.text = calculation.underlyingTicker
            underlyingPriceLabel.text = calculation.underlyingPrice
            callOrPutSegmentedControl.selectedSegmentIndex = Int(calculation.callOrPutChoice)
            buyOrSellSegmentedControl.selectedSegmentIndex = Int(calculation.buyOrSellChoice)
            buyOrSellChoice = calculation.buyOrSellChoice
            callOrPutChoice = calculation.callOrPutChoice
            strategy = calculation.strategy
            StrategyTitleLabel.text = calculation.strategyTitleLabel
            callAndPutLabel.text = calculation.callOrPutLabel
            callPriceTextField.text = calculation.callPrice
            strikePriceTextField.text = calculation.strikePrice
            numofContractsTextField.text = calculation.numOfContracts
            expiryDateTextField.text = calculation.expiryDate
        } else {
            callOrPutSegmentedControl.selectedSegmentIndex = 0
            buyOrSellSegmentedControl.selectedSegmentIndex = 0
            underlyingTickerTextField.text = ""
            strategy = 0
            StrategyTitleLabel.text = "Long Call"
            callAndPutLabel.text = "Price of 1 Call"
            callPriceTextField.text = ""
            underlyingPriceLabel.text = ""
            strikePriceTextField.text = ""
            numofContractsTextField.text = ""
            expiryDateTextField.text = ""
        }
    }
    func passData()-> ([Double],String){
        tempArr.removeAll()
        tempArr.append(self.underlyingPrice)
        tempArr.append(self.callPrice)
        tempArr.append(self.strikePrice)
        tempArr.append(self.numOfOptions)
        tempArr.append(self.strategy)
        return (tempArr,self.underlyingTicker)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    @IBAction func calculateCostButtonTapped(_ sender: UIButton) {
        calculateCallTotalCost()
    }
    @IBAction func graphButtonTapped(_ sender: Any) {
    }
    @IBAction func unwindWithSegue (_ segue: UIStoryboardSegue){

    }
    
    @IBAction func buyOrSellSelected(_ sender: UISegmentedControl) {
        switch buyOrSellSegmentedControl.selectedSegmentIndex{
        case 0:
            //Buy
            buyOrSellChoice = 0
        case 1:
            //Sell
            buyOrSellChoice = 1
        default:
            print("unknown option identifier")
        }
        selectStrategy()
    }
    
    @IBAction func strategySelected(_ sender: UISegmentedControl) {
        switch callOrPutSegmentedControl.selectedSegmentIndex {
        case 0:
            //Call
            callOrPutChoice = 0
        case 1:
            //Put
            callOrPutChoice = 1
        default:
            preconditionFailure("Unexpected index.")
        }
        selectStrategy()
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {   //delegate method
        if underlyingTickerTextField.resignFirstResponder(){
            self.getSymbolCurrentPrice(){ stockPrice in
                self.underlyingPrice = stockPrice
            }
        }
        if expiryDateTextField.resignFirstResponder(){
            if self.expiryDateTextField.isFirstResponder {
                self.expiryDateTextField.resignFirstResponder()
            }
            if let expiryDateText = self.numofContractsTextField.text{
                self.expiryDate = expiryDateText
            }
        }
        return true
    }
    func selectStrategy(){
        if callOrPutChoice == 0 && buyOrSellChoice == 0{
            //long call
            strategy = 0
            StrategyTitleLabel.text = "Long Call"
            callAndPutLabel.text = "Price of 1 Call"
        } else if callOrPutChoice == 0 && buyOrSellChoice == 1{
            //naked call
            strategy = 1
            StrategyTitleLabel.text = "Naked Call"
            callAndPutLabel.text = "Price of 1 Call"
        } else if callOrPutChoice == 1 && buyOrSellChoice == 0{
            //long put
            strategy = 2
            StrategyTitleLabel.text = "Long Put"
            callAndPutLabel.text = "Price of 1 Put"
        } else if callOrPutChoice == 1 && buyOrSellChoice == 1{
            //naked put
            strategy = 3
            StrategyTitleLabel.text = "Naked Put"
            callAndPutLabel.text = "Price of 1 Put"
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //if-let new clause to our guard statement to check that the destination view controller of our segue is of type ListCalcTableViewController. This allows us to safely type case our segue's destination view controller and access it for each case of our switch-statement.
        guard let identifier = segue.identifier else{return}
        
        switch identifier {
        case "displayGraph":
            print("graph button tapped")
            // set variables to self
            //if destination is profitgraph, cast profit as profitgraphviewcontroller
            setSelfValues()
            
            if let profitGraphViewController = segue.destination as? ProfitGraphViewController{
                profitGraphViewController.delegate = nil
                profitGraphViewController.delegate = self}
            
        case "save" where calculation != nil: //when it is not a new
            
            //Set the new calculation's title and content to the corresponding text field and text view text values. If either value is nil, we provide an empty string as the default value using the nil coalescing operation (??)
//            if strategySegmentedControl.selectedSegmentIndex == Int((calculation?.strategy)!){
//                calculation?.strategy = Double(strategySegmentedControl.selectedSegmentIndex)
//            }else{calculation?.strategy = strategy}
           
//            if callOrPutSegmentedControl.selectedSegmentIndex == Int((calculation?.callOrPutChoice)!){
//                calculation?.callOrPutChoice = Double(callOrPutSegmentedControl.selectedSegmentIndex)
//            }else{calculation?.callOrPutChoice = callOrPutChoice}
//
//            if buyOrSellSegmentedControl.selectedSegmentIndex == Int((calculation?.buyOrSellChoice)!){
//                calculation?.buyOrSellChoice = Double(buyOrSellSegmentedControl.selectedSegmentIndex)
//
//            }else{calculation?.buyOrSellChoice = buyOrSellChoice}
            calculation?.callOrPutChoice = callOrPutChoice
            calculation?.buyOrSellChoice = buyOrSellChoice
            calculation?.strategy = strategy
            calculation?.underlyingTicker = underlyingTickerTextField.text ?? ""
            calculation?.underlyingPrice = underlyingPriceLabel.text ?? ""
            calculation?.strategyTitleLabel = StrategyTitleLabel.text ?? ""
            calculation?.callOrPutLabel = callAndPutLabel.text ?? ""
            calculation?.callPrice = callPriceTextField.text ?? ""
            calculation?.strikePrice = strikePriceTextField.text ?? ""
            calculation?.numOfContracts = numofContractsTextField.text ?? ""
            calculation?.expiryDate = expiryDateTextField.text ?? ""
            calculation?.modificationTime = Date()
            
            //in order to access the destination view controller's properties, we need to type cast the destination view controller to type ListCalculationsTableViewController
            CoreDataHelper.saveCalculation()
            
        case "save" where calculation == nil: //new calculation:
            let calculation = CoreDataHelper.newCalculation()
            calculation.callOrPutChoice = callOrPutChoice
            calculation.buyOrSellChoice = buyOrSellChoice
            calculation.strategy = strategy
            calculation.underlyingTicker = underlyingTickerTextField.text ?? ""
            calculation.underlyingPrice = underlyingPriceLabel.text ?? ""
            calculation.strategyTitleLabel = StrategyTitleLabel.text ?? ""
            calculation.callOrPutLabel = callAndPutLabel.text ?? ""
            calculation.callPrice = callPriceTextField.text ?? ""
            calculation.strikePrice = strikePriceTextField.text ?? ""
            calculation.numOfContracts = numofContractsTextField.text ?? ""
            calculation.expiryDate = expiryDateTextField.text ?? ""
            calculation.modificationTime = Date()
            
            CoreDataHelper.saveCalculation()
            
        case "cancel":
            print("cancel button tapped")
            
        default:
            print("unexpected segue")
        }
    }
}


extension CalculatorViewController{
    func setSelfValues(){
        if let underlyingPriceText = underlyingPriceLabel.text, let underlyingPriceDouble = Double(underlyingPriceText){
            self.underlyingPrice = underlyingPriceDouble
        }
        if let callPriceText = self.callPriceTextField.text, let callPriceDouble = Double(callPriceText){
            self.callPrice = callPriceDouble
        }
        if let strikePriceText = self.strikePriceTextField.text, let strikePriceDouble = Double(strikePriceText){
            self.strikePrice = strikePriceDouble
        }
        if let numOfContractsText = self.numofContractsTextField.text, let numOfContractsDouble = Double(numOfContractsText) {self.numOfOptions = numOfContractsDouble * 100
        }
    }
    
    func calculateCallTotalCost(){
        guard let callPrice = self.callPriceTextField.text
            else {return}
        guard let numOfContracts = self.numofContractsTextField.text
            else{return}
        let totalnumOfCallOptions = Double(numOfContracts)! * 100
        let totalCallCost = Double(callPrice)! * totalnumOfCallOptions
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
//                let stockPriceRounded = 20.0
                self.underlyingPriceLabel.text = String(stockPriceRounded)
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


