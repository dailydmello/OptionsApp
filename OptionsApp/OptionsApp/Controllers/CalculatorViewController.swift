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
    
    @IBOutlet weak var underlyingView: UIView!
    @IBOutlet weak var underlyingTickerTextField: UITextField!
    @IBOutlet weak var underlyingPriceLabel: UILabel!
    @IBOutlet weak var underlyingPriceTextField: SymbolTextField!
    @IBOutlet weak var optionView: UIView!
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
    @IBOutlet weak var cancelBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var saveBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var buyOrSellSegmentedControl: UISegmentedControl!
    
    var calculation: Calculation?
    var tempArr = [Double]() //temporary array for calculation
    var underlyingTicker: String = ""
    var underlyingPrice: Double = 0
    var callPrice: Double = 0
    var strikePrice: Double = 0
    var numOfOptions: Double = 0
    var strategy: Double = 0
    var expiryDate: String = ""
    var buyOrSellChoice: Double = 0
    var callOrPutChoice: Double = 0
    var entryCost: Double = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //styling
        setupViews()
        //get rid of keyboard
        underlyingTickerTextField.delegate = self
        expiryDateTextField.delegate = self
        //text inputed, done clicked
        inputEntered()
        
        //load existing calculation
        if let calculation = calculation {
            underlyingTickerTextField.text = calculation.underlyingTicker
            underlyingPriceTextField.text = calculation.underlyingPrice
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
            costLabel.text = calculation.entryCost
          
        //new calculation after add button hit
        } else {
            callOrPutSegmentedControl.selectedSegmentIndex = 0
            buyOrSellSegmentedControl.selectedSegmentIndex = 0
            underlyingTickerTextField.text = ""
            underlyingPriceTextField.text = ""
            strategy = 0
            StrategyTitleLabel.text = "Long Call"
            callAndPutLabel.text = "Price of Call:"
            callPriceTextField.text = ""
            strikePriceTextField.text = ""
            numofContractsTextField.text = ""
            expiryDateTextField.text = ""
            costLabel.text = ""
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
    
    func setupViews(){
        //cancel button styling
        cancelBarButtonItem.setTitleTextAttributes([
            NSAttributedStringKey.font: UIFont(name: "ProximaNova-Light", size: 18.0)!,
            NSAttributedStringKey.foregroundColor: UIColor.tcWhite],
                                                  for: .normal)
        //save button styling
        saveBarButtonItem.setTitleTextAttributes([
            NSAttributedStringKey.font: UIFont(name: "ProximaNova-Light", size: 18.0)!,
            NSAttributedStringKey.foregroundColor: UIColor.tcWhite],
                                                  for: .normal)
        //first background square styling
        underlyingView.layer.cornerRadius = 8
        underlyingView.layer.masksToBounds = true
        
        //second background square styling
        optionView.layer.cornerRadius = 8
        optionView.layer.masksToBounds = true
        
        //graph button styling
        graphButton.layer.cornerRadius = 8
        graphButton.layer.masksToBounds = true
        
        //calculate cost button styling
        calculateCostButton.layer.cornerRadius = 8
        calculateCostButton.layer.masksToBounds = true
        calculateCostButton.layer.borderWidth = 1
        calculateCostButton.layer.borderColor = UIColor.tcSeafoamGreen.cgColor
        
        //graph button styling
        graphButton.layer.cornerRadius = 8
        graphButton.layer.masksToBounds = true
        graphButton.layer.borderWidth = 1
        graphButton.layer.borderColor = UIColor.tcSeafoamGreen.cgColor
    
        //cost-premium label styling
        costLabel.layer.cornerRadius = 8
        costLabel.layer.masksToBounds = true
    }
    
    func inputEntered(){
        underlyingPriceTextField.calculateButtonAction = {
            if self.underlyingPriceTextField.isFirstResponder {
                self.underlyingPriceTextField.resignFirstResponder()
            }
            if let underlyingPriceText = self.underlyingPriceTextField.text, let underlyingPriceDouble = Double(underlyingPriceText){
                self.underlyingPrice = underlyingPriceDouble
            }
        }
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
        
    }

    @IBAction func calculateCostButtonTapped(_ sender: UIButton) {
        calculateOptionTotalCost()
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
        setStrategy()
    }
    
    @IBAction func callOrPutSelected(_ sender: UISegmentedControl) {
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
        setStrategy()
    }
    
    func setStrategy(){
        if callOrPutChoice == 0 && buyOrSellChoice == 0{
            //long call
            strategy = 0
            StrategyTitleLabel.text = "Long Call"
            callAndPutLabel.text = "Price of Call:"
        } else if callOrPutChoice == 0 && buyOrSellChoice == 1{
            //naked call
            strategy = 1
            StrategyTitleLabel.text = "Naked Call"
            callAndPutLabel.text = "Price of Call:"
        } else if callOrPutChoice == 1 && buyOrSellChoice == 0{
            //long put
            strategy = 2
            StrategyTitleLabel.text = "Long Put"
            callAndPutLabel.text = "Price of Put:"
        } else if callOrPutChoice == 1 && buyOrSellChoice == 1{
            //naked put
            strategy = 3
            StrategyTitleLabel.text = "Naked Put"
            callAndPutLabel.text = "Price of Put:"
        }
    }
    
    //get rid of keypad
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if let underlyingTickerText = self.underlyingTickerTextField.text{
            self.underlyingTicker = underlyingTickerText
        }
        if let expiryDateText = self.numofContractsTextField.text{
            self.expiryDate = expiryDateText
        }
        return true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier else{return}
        
        switch identifier {
        case "displayGraph":
            calculateOptionTotalCost()
            setSelfValues() //hacky fix to get correct values passed through delegate
            
            //delegate implementation to pass data
            if let profitGraphViewController = segue.destination as? ProfitGraphViewController{
                profitGraphViewController.delegate = nil
                profitGraphViewController.delegate = self}
            
        case "save" where calculation != nil: //existing calculation modified and saved
            
            calculation?.callOrPutChoice = callOrPutChoice
            calculation?.buyOrSellChoice = buyOrSellChoice
            calculation?.strategy = strategy
            calculation?.underlyingTicker = underlyingTickerTextField.text ?? ""
            calculation?.underlyingPrice = underlyingPriceTextField.text ?? ""
            calculation?.strategyTitleLabel = StrategyTitleLabel.text ?? ""
            calculation?.callOrPutLabel = callAndPutLabel.text ?? ""
            calculation?.callPrice = callPriceTextField.text ?? ""
            calculation?.strikePrice = strikePriceTextField.text ?? ""
            calculation?.numOfContracts = numofContractsTextField.text ?? ""
            calculation?.expiryDate = expiryDateTextField.text ?? ""
            calculation?.entryCost = costLabel.text ?? ""
            calculation?.modificationTime = Date()
            
            CoreDataHelper.saveCalculation()
            
        case "save" where calculation == nil: //new calculation saved
            let calculation = CoreDataHelper.newCalculation()
            calculation.callOrPutChoice = callOrPutChoice
            calculation.buyOrSellChoice = buyOrSellChoice
            calculation.strategy = strategy
            calculation.underlyingTicker = underlyingTickerTextField.text ?? ""
            calculation.underlyingPrice = underlyingPriceTextField.text ?? ""
            calculation.strategyTitleLabel = StrategyTitleLabel.text ?? ""
            calculation.callOrPutLabel = callAndPutLabel.text ?? ""
            calculation.callPrice = callPriceTextField.text ?? ""
            calculation.strikePrice = strikePriceTextField.text ?? ""
            calculation.numOfContracts = numofContractsTextField.text ?? ""
            calculation.expiryDate = expiryDateTextField.text ?? ""
            calculation.entryCost = costLabel.text ?? ""
            calculation.modificationTime = Date()
            
            CoreDataHelper.saveCalculation()
            
        case "cancel":
            print("cancel button tapped")
            
        default:
            print("unexpected segue")
        }
    }
    
    func setSelfValues(){
        if let underlyingPriceText = underlyingPriceTextField.text, let underlyingPriceDouble = Double(underlyingPriceText){
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
    
    func calculateOptionTotalCost(){
        if let callPriceText = self.callPriceTextField.text, let callPriceDouble = Double(callPriceText){
            self.callPrice = callPriceDouble
        }
        
        if let numOfContractsText = self.numofContractsTextField.text, let numOfContractsDouble = Double(numOfContractsText) {self.numOfOptions = numOfContractsDouble * 100
        }
        let entryCostText = String(callPrice * numOfOptions)
        self.costLabel.text = entryCostText.dropLast(2)
    }
}




