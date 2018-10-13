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
    
    @IBOutlet weak var backBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var lineChartView: LineChartView!
    @IBOutlet weak var updateMaxTextField: SymbolTextField!
    @IBOutlet weak var updateMinTextField: SymbolTextField!
    @IBOutlet weak var updateButton: UIButton!
    @IBOutlet weak var rangeView: UIView!
    
    
    var strikePrice: Double = 0
    var underlyingTicker: String = ""
    var underlyingPrice: Double = 0
    var numOfOptions: Double = 0
    var callPrice: Double = 0
    var delegate: CalculatorViewControllerDelegate?
    var strategy: Double = 0
    var underlyingMin: Double = 0
    var underlyingMax: Double = 0
    var limit: Double = 0
    var costOrPremium: Double = 0
    var formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        minMaxChanged()
        
        if let delegate = delegate {
            let newData = delegate.passData()
            underlyingTicker = newData.1
            underlyingPrice = (100 * Double(newData.0[0])).rounded()/100
            callPrice = newData.0[1]
            strikePrice = newData.0[2]
            numOfOptions = newData.0[3]
            strategy = newData.0[4]
            
            //min and max determined within 20% of underlying
            underlyingMin = ((underlyingPrice - underlyingPrice * 0.20) * 100).rounded()/100
            underlyingMax = ((underlyingPrice + underlyingPrice * 0.20) * 100).rounded()/100
        }
        updateMaxTextField.text = String(underlyingMax)
        updateMinTextField.text = String(underlyingMin)
        updateChartWithData(underlyingMin: underlyingMin,underlyingMax: underlyingMax)
    }
    func setupViews(){
        //back button styling
        backBarButtonItem.setTitleTextAttributes([
            NSAttributedStringKey.font: UIFont(name: "ProximaNova-Light", size: 18.0)!,
            NSAttributedStringKey.foregroundColor: UIColor.tcWhite],
                                                   for: .normal)
        //top square styling
        rangeView.layer.cornerRadius = 8
        rangeView.layer.masksToBounds = true
        
        //update button styling
        updateButton.layer.borderWidth = 1
        updateButton.layer.cornerRadius = 8
        updateButton.layer.borderColor =  UIColor.tcSeafoamGreen.cgColor
    }
    @IBAction func updateButtonTapped(_ sender: UIButton) {
        updateChartWithData(underlyingMin: underlyingMin, underlyingMax: underlyingMax)
    }
    func minMaxChanged(){
        updateMinTextField.calculateButtonAction = {
            if self.updateMinTextField.isFirstResponder {
                self.updateMinTextField.resignFirstResponder()
            }
            if let updateMinText = self.updateMinTextField.text, let updateMinDouble = Double(updateMinText){
                self.underlyingMin = (100 * updateMinDouble).rounded()/100
            }
        }
        updateMaxTextField.calculateButtonAction = {
            if self.updateMaxTextField.isFirstResponder {
                self.updateMaxTextField.resignFirstResponder()
            }
            if let updateMaxText = self.updateMaxTextField.text, let updateMaxDouble = Double(updateMaxText){
                self.underlyingMax = (100 * updateMaxDouble).rounded()/100
            }
        }
    }
    
    func updateChartWithData(underlyingMin: Double, underlyingMax: Double){
        var chartDataEntries = [ChartDataEntry]()
        var underlyingValuesArr = [Double]()
        var tempArr: [Double] = [0]
        var profits: [Double] = []
        var graphProfits: [Double] = []
        var graphUnderlyingVals: [Double] = []

        switch strategy{
            
        //Long Call Implementation
        case 0:
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
            costOrPremium = -1 * callPrice * numOfOptions
            limit = strikePrice + callPrice
            graphProfits = profits
            graphUnderlyingVals = underlyingValuesArr
        
        //Naked Call Implementation
        case 1:
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
            costOrPremium = numOfOptions * callPrice
            limit = strikePrice + callPrice
            graphProfits = profits
            graphUnderlyingVals = underlyingValuesArr
        
        //Long put implementation
        case 2:
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
            costOrPremium = -1 * callPrice * numOfOptions
            limit = strikePrice - callPrice
            graphProfits = flipArray(flipMe: profits)
            graphUnderlyingVals = flipArray(flipMe:underlyingValuesArr)
        
        //Naked put implementation
        case 3:
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
            costOrPremium = numOfOptions * callPrice
            limit = strikePrice - callPrice
            graphProfits = flipArray(flipMe: profits)
            graphUnderlyingVals = flipArray(flipMe:underlyingValuesArr)
        default:
            print("Unidentified Case")
        }
        
        //DATA FOR GRAPH
        for i in 0..<graphProfits.count {
            let dataEntry = ChartDataEntry(x: graphUnderlyingVals[i], y: graphProfits[i])
            chartDataEntries.append(dataEntry)
        }
        
        //CREATE DATA SET
        let set1 = LineChartDataSet(values: chartDataEntries, label: "Profits ($)")
        set1.setColor(UIColor.tcSeafoamGreen)
        set1.fillColor = UIColor.tcSeafoamGreen
        set1.circleRadius = 0
        set1.lineWidth = 2.0
        set1.fillAlpha = 0.8
        set1.drawFilledEnabled = false
        set1.drawValuesEnabled = false
        let linechartData = LineChartData(dataSet: set1)
        lineChartView.data = linechartData
        
        //AXIS ARE BEING SET
        lineChartView.rightAxis.enabled = false
        
        let yAxis = lineChartView.leftAxis
        yAxis.valueFormatter = DefaultAxisValueFormatter(formatter: formatter)
        yAxis.enabled = true
        yAxis.drawGridLinesEnabled = true
        yAxis.labelFont = UIFont(name: "ProximaNova-Regular", size: 11.0)!
        yAxis.labelTextColor = UIColor.tcWhite
        
        let xAxis = lineChartView.xAxis
        xAxis.valueFormatter = DefaultAxisValueFormatter(formatter: formatter)
        xAxis.enabled = true
        xAxis.labelFont = UIFont(name: "ProximaNova-Regular", size: 11.0)!
        xAxis.labelTextColor = UIColor.tcWhite
        
        //LIMIT LINES ARE BEING SET
        let ll1 = ChartLimitLine(limit: limit, label: "Break Even Price")
        ll1.lineWidth = 1.0
        ll1.labelPosition = .rightTop
        ll1.drawLabelEnabled = true
        ll1.valueFont = .systemFont(ofSize: 10)
        ll1.lineColor = NSUIColor(red: 0/255.0, green: 176/255.0, blue: 255/255.0, alpha: 1.0)
        ll1.valueTextColor = NSUIColor(red: 0/255.0, green: 176/255.0, blue: 255/255.0, alpha: 1.0)
       
        let ll3 = ChartLimitLine(limit: costOrPremium, label: "Cost/Premium")
        ll3.lineWidth = 1.0
        ll3.labelPosition = .leftTop
        ll3.drawLabelEnabled = true
        ll3.valueFont = .systemFont(ofSize: 10)
        ll3.lineColor = UIColor.tcWhite
        ll3.valueTextColor = UIColor.tcWhite
        
        let ll2 = ChartLimitLine(limit: strikePrice, label: "Strike Price")
        ll2.lineWidth = 1.0
        ll2.drawLabelEnabled = true
        ll2.labelPosition = .leftBottom
        ll2.valueFont = .systemFont(ofSize: 10)
        ll2.lineColor = NSUIColor(red: 237.0/255.0, green: 91.0/255.0, blue: 91.0/255.0, alpha: 1.0)
        ll2.valueTextColor = NSUIColor(red: 237.0/255.0, green: 91.0/255.0, blue: 91.0/255.0, alpha: 1.0)
        
        xAxis.drawLimitLinesBehindDataEnabled = true
        xAxis.addLimitLine(ll1)
        xAxis.addLimitLine(ll2)
        
        yAxis.drawLimitLinesBehindDataEnabled = true
        yAxis.addLimitLine(ll3)
        
        lineChartView.legend.font = UIFont(name: "ProximaNova-Semibold", size: 14.0)!
        lineChartView.legend.textColor = UIColor.tcWhite
        lineChartView.chartDescription?.enabled = false
    
        lineChartView.animate(yAxisDuration: 1.0)
    }
}

extension ProfitGraphViewController{
    //for graphing
    func flipArray(flipMe:[Double]) -> [Double]{
        var reversedArr = [Double]()
        for arrayIndex in stride(from: flipMe.count - 1, through: 0, by: -1) {
            reversedArr.append(flipMe[arrayIndex])
        }
        return reversedArr
    }
    //strides for developing graphs in iOS charts library, x-axis points
    func reverseStride(underlyingMax: Double, underlyingMin: Double) -> [Double]{
        var tempArr = [Double]()
        for i in stride(from: underlyingMax, through: underlyingMin, by: -1){
            tempArr.append(i)
        }
        return tempArr
    }
    func regularStride(underlyingMin: Double, underlyingMax: Double) -> [Double]{
        var tempArr = [Double]()
        for i in stride(from: underlyingMin, through: underlyingMax, by: 1){
            tempArr.append(i)
        }
        return tempArr
    }
    
}





