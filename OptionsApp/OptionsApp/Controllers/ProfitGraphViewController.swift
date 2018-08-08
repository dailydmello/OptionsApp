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


class ProfitGraphViewController: UIViewController, ChartViewDelegate{
    
    var strikePrice: Double = 0
    var underlyingTicker: String = ""
    var underlyingPrice: Double = 0
    var numOfOptions: Double = 0
    var callPrice: Double = 0
    var delegate: CalculatorViewControllerDelegate?
    var strategy: Double = 0
    var updateMin: Double = 0
    var updateMax: Double = 0
    
    @IBOutlet weak var backBarButtonItem: UIBarButtonItem!
    
    @IBOutlet weak var lineChartView: LineChartView!
   
    @IBOutlet weak var updateMaxTextField: SymbolTextField!
    @IBOutlet weak var updateMinTextField: SymbolTextField!
    
    @IBOutlet weak var updateButton: UIButton!
    @IBOutlet weak var rangeView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        updateMinTextField.calculateButtonAction = {
            if self.updateMinTextField.isFirstResponder {
                self.updateMinTextField.resignFirstResponder()
            }
            if let updateMinText = self.updateMinTextField.text, let updateMinDouble = Double(updateMinText){
                self.updateMin = (100 * updateMinDouble).rounded()/100
            }
            print(self.updateMin)
        }
        

        updateMaxTextField.calculateButtonAction = {
            if self.updateMaxTextField.isFirstResponder {
                self.updateMaxTextField.resignFirstResponder()
            }
            if let updateMaxText = self.updateMaxTextField.text, let updateMaxDouble = Double(updateMaxText){
                self.updateMax = (100 * updateMaxDouble).rounded()/100
            }
            print(self.updateMax)
        }
        
        if let delegate = delegate {
            //[underlyingPrice,priceOfCall,strikePrice,numOfOptions]
            let newData = delegate.passData()
            print(newData)
            underlyingTicker = newData.1
            underlyingPrice = (100 * Double(newData.0[0])).rounded()/100
            callPrice = newData.0[1]
            strikePrice = newData.0[2]
            numOfOptions = newData.0[3]
            strategy = newData.0[4]
        }
        //print(strategy)
       updateChartWithData()
    }
    override func viewWillAppear(_ animated: Bool) {
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier else{return}
        switch identifier {
        case "back":
            print("back button tapped")
        default:
            print("unexpected segue")
        }
    }

    func reverseStride(underlyingMax: Double, underlyingMin: Double) -> [Double]{
        var tempArr = [Double]()
        for i in stride(from: underlyingMax, through: underlyingMin, by: -1){
            tempArr.append(i)
        }
        return tempArr
    }
    func setupViews(){
        backBarButtonItem.setTitleTextAttributes([
            NSAttributedStringKey.font: UIFont(name: "ProximaNova-Light", size: 18.0)!,
            NSAttributedStringKey.foregroundColor: UIColor.tcWhite],
                                                   for: .normal)
        rangeView.layer.cornerRadius = 8
        rangeView.layer.masksToBounds = true
        
        updateButton.layer.borderWidth = 1
        updateButton.layer.cornerRadius = 8
        updateButton.layer.borderColor =  UIColor.tcSeafoamGreen.cgColor
    }
    
    func regularStride(underlyingMin: Double, underlyingMax: Double) -> [Double]{
        var tempArr = [Double]()
        for i in stride(from: underlyingMin, through: underlyingMax, by: 1){
            tempArr.append(i)
        }
        return tempArr
    }
    
    func flipArray(flipMe:[Double]) -> [Double]{
        var reversedArr = [Double]()
        for arrayIndex in stride(from: flipMe.count - 1, through: 0, by: -1) {
            reversedArr.append(flipMe[arrayIndex])
        }
        return reversedArr
    }
    
    @IBAction func updateButtonTapped(_ sender: UIButton) {
        if let updateMinText = self.updateMinTextField.text, let updateMinDouble = Double(updateMinText){
            self.updateMin = (100 * updateMinDouble).rounded()/100
        }
        if let updateMaxText = self.updateMaxTextField.text, let updateMaxDouble = Double(updateMaxText){
            self.updateMax = (100 * updateMaxDouble).rounded()/100
        }
        
        updateChartWithNewMinMax()
    }
    
    func updateChartWithNewMinMax(){
        var chartDataEntries = [ChartDataEntry]()
        var underlyingValuesArr = [Double]()
        var tempArr: [Double] = [0]
        var profits: [Double] = []
        var graphProfits: [Double] = []
        var graphUnderlyingVals: [Double] = []
        let underlyingMin = updateMin
        let underlyingMax = updateMax

        switch strategy{
        case 0:
            print("Long Call graphed")
            //Long Call Implementation
            underlyingValuesArr = regularStride(underlyingMin: underlyingMin, underlyingMax: underlyingMax)
            for underlying in underlyingValuesArr{
                if underlying > strikePrice {
                    let diff = underlying - strikePrice
                    tempArr.append(diff)
                    profits.append(-1 * numOfOptions * callPrice + numOfOptions * tempArr.max()!)
                }else{
                    profits.append(-1 * numOfOptions * callPrice)
                }
            }
            graphProfits = profits
            graphUnderlyingVals = underlyingValuesArr
        case 1:
            print("Naked Call graphed")
            //Naked Call Implementation
            underlyingValuesArr = regularStride(underlyingMin: underlyingMin, underlyingMax: underlyingMax)
            for underlying in underlyingValuesArr{
                if underlying > strikePrice {
                    let diff = strikePrice - underlying
                    tempArr.append(diff)
                    profits.append(numOfOptions * callPrice + numOfOptions * tempArr.min()!)
                }else{
                    profits.append(numOfOptions * callPrice)
                }
            }
            graphProfits = profits
            graphUnderlyingVals = underlyingValuesArr
        case 2:
            print("Long put graphed")
            //Long put implementation
            underlyingValuesArr = reverseStride(underlyingMax: underlyingMax, underlyingMin: underlyingMin)
            for underlying in underlyingValuesArr{
                if underlying < strikePrice {
                    let diff = strikePrice - underlying
                    tempArr.append(diff)
                    //print(tempArr)
                    profits.append(-1 * numOfOptions * callPrice + numOfOptions * tempArr.max()!)
                }else{
                    profits.append(-1 * numOfOptions * callPrice)
                }
            }
            graphProfits = flipArray(flipMe: profits)
            graphUnderlyingVals = flipArray(flipMe:underlyingValuesArr)
        case 3:
            print("Naked Put graphed")
            //Naked put implementation
            underlyingValuesArr = reverseStride(underlyingMax: underlyingMax, underlyingMin: underlyingMin)
            for underlying in underlyingValuesArr{
                if underlying < strikePrice {
                    let diff = strikePrice - underlying
                    tempArr.append(diff)
                    //print(tempArr)
                    profits.append( numOfOptions * callPrice - numOfOptions * tempArr.max()!)
                }else{
                    profits.append( numOfOptions * callPrice)
                }
            }
            graphProfits = flipArray(flipMe: profits)
            graphUnderlyingVals = flipArray(flipMe:underlyingValuesArr)
        default:
            print("Unidentified Case")
        }
        for i in 0..<graphProfits.count {
            //print("underlying: \(graphUnderlyingVals[i]) and profit \(graphProfits[i])")
            let dataEntry = ChartDataEntry(x: graphUnderlyingVals[i], y: graphProfits[i])
            //print(dataEntry)
            chartDataEntries.append(dataEntry)
        }
        let set1 = LineChartDataSet(values: chartDataEntries, label: "Profits")
        let linechartData = LineChartData(dataSet: set1)
        lineChartView.data = linechartData
        set1.circleRadius = 0
        set1.lineWidth = 2.5
        set1.fillAlpha = 0.8
        set1.setColor(UIColor.tcSeafoamGreen)
        set1.fillColor = UIColor.tcSeafoamGreen
        set1.drawFilledEnabled = true
        set1.drawValuesEnabled = false
        
        lineChartView.leftAxis.enabled = true
        lineChartView.leftAxis.drawGridLinesEnabled = true
        lineChartView.rightAxis.enabled = false
        lineChartView.xAxis.enabled = true
        lineChartView.animate(yAxisDuration: 0.8)
    }
    
    func updateChartWithData(){
        var chartDataEntries = [ChartDataEntry]()
        var underlyingValuesArr = [Double]()
        var tempArr: [Double] = [0]
        var profits: [Double] = []
        var graphProfits: [Double] = []
        var graphUnderlyingVals: [Double] = []
//        let underlyingMin = underlyingPrice - 5
//        let underlyingMax = underlyingPrice + 5
//        print(underlyingPrice)
//        let underlyingMin = (underlyingPrice - underlyingPrice * 0.20)
//        let underlyingMax = (underlyingPrice + underlyingPrice * 0.20)
//        print(underlyingMin)
//        print(underlyingMax)
        let underlyingMin = ((underlyingPrice - underlyingPrice * 0.20) * 100).rounded()/100
        let underlyingMax = ((underlyingPrice + underlyingPrice * 0.20) * 100).rounded()/100
        updateMaxTextField.text = String(underlyingMax)
        updateMinTextField.text = String(underlyingMin)
        
        switch strategy{
        case 0:
            print("Long Call graphed")
            //Long Call Implementation
            underlyingValuesArr = regularStride(underlyingMin: underlyingMin, underlyingMax: underlyingMax)
            for underlying in underlyingValuesArr{
                if underlying > strikePrice {
                    let diff = underlying - strikePrice
                    tempArr.append(diff)
                    profits.append(-1 * numOfOptions * callPrice + numOfOptions * tempArr.max()!)
                }else{
                    profits.append(-1 * numOfOptions * callPrice)
                }
            }
            graphProfits = profits
            graphUnderlyingVals = underlyingValuesArr
        case 1:
            print("Naked Call graphed")
            //Naked Call Implementation
            underlyingValuesArr = regularStride(underlyingMin: underlyingMin, underlyingMax: underlyingMax)
            for underlying in underlyingValuesArr{
                if underlying > strikePrice {
                    let diff = strikePrice - underlying
                    tempArr.append(diff)
                    profits.append(numOfOptions * callPrice + numOfOptions * tempArr.min()!)
                }else{
                    profits.append(numOfOptions * callPrice)
                }
            }
            graphProfits = profits
            graphUnderlyingVals = underlyingValuesArr
        case 2:
            print("Long put graphed")
            //Long put implementation
            underlyingValuesArr = reverseStride(underlyingMax: underlyingMax, underlyingMin: underlyingMin)
            for underlying in underlyingValuesArr{
                if underlying < strikePrice {
                    let diff = strikePrice - underlying
                    tempArr.append(diff)
                    //print(tempArr)
                    profits.append(-1 * numOfOptions * callPrice + numOfOptions * tempArr.max()!)
                }else{
                    profits.append(-1 * numOfOptions * callPrice)
                }
            }
            graphProfits = flipArray(flipMe: profits)
            graphUnderlyingVals = flipArray(flipMe:underlyingValuesArr)
        case 3:
            print("Naked Put graphed")
            //Naked put implementation
            underlyingValuesArr = reverseStride(underlyingMax: underlyingMax, underlyingMin: underlyingMin)
            for underlying in underlyingValuesArr{
                if underlying < strikePrice {
                    let diff = strikePrice - underlying
                    tempArr.append(diff)
                    //print(tempArr)
                    profits.append( numOfOptions * callPrice - numOfOptions * tempArr.max()!)
                }else{
                    profits.append( numOfOptions * callPrice)
                }
            }
            graphProfits = flipArray(flipMe: profits)
            graphUnderlyingVals = flipArray(flipMe:underlyingValuesArr)
        default:
            print("Unidentified Case")
        }
        for i in 0..<graphProfits.count {
            //print("underlying: \(graphUnderlyingVals[i]) and profit \(graphProfits[i])")
            let dataEntry = ChartDataEntry(x: graphUnderlyingVals[i], y: graphProfits[i])
            //print(dataEntry)
            chartDataEntries.append(dataEntry)
        }
        let set1 = LineChartDataSet(values: chartDataEntries, label: "Profits ($)")
        let linechartData = LineChartData(dataSet: set1)
//        set1.setColor(UIColor(red: 89/255, green: 218/255, blue: 164/255, alpha: 1))
        set1.setColor(UIColor.tcSeafoamGreen)
        set1.fillColor = UIColor.tcSeafoamGreen
        set1.circleRadius = 0
        set1.lineWidth = 2.5
        set1.fillAlpha = 0.8
        set1.drawFilledEnabled = false
        set1.drawValuesEnabled = false
        lineChartView.data = linechartData
        
        //lineChartView.leftAxis.
        lineChartView.legend.font = UIFont(name: "ProximaNova-Semibold", size: 14.0)!
        lineChartView.legend.textColor = UIColor.tcWhite
        lineChartView.chartDescription?.enabled = false
        lineChartView.leftAxis.enabled = true
        lineChartView.leftAxis.drawGridLinesEnabled = true
        lineChartView.leftAxis.labelFont = UIFont(name: "ProximaNova-Regular", size: 11.0)!
        lineChartView.leftAxis.labelTextColor = UIColor.tcWhite
        lineChartView.rightAxis.enabled = false
        lineChartView.xAxis.enabled = true
        lineChartView.xAxis.labelFont = UIFont(name: "ProximaNova-Regular", size: 11.0)!
        lineChartView.xAxis.labelTextColor = UIColor.tcWhite
        lineChartView.animate(yAxisDuration: 0.8)
    }
}





