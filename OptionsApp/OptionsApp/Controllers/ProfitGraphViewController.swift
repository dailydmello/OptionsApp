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
    
    @IBOutlet weak var lineChartView: LineChartView!
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
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
        print(strategy)
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
    
    func updateChartWithData(){
        var chartDataEntries = [ChartDataEntry]()
        var underlyingValuesArr = [Double]()
        var tempArr: [Double] = [0]
        var profits: [Double] = []
        var graphProfits: [Double] = []
        var graphUnderlyingVals: [Double] = []
//        let underlyingMin = underlyingPrice - 5
//        let underlyingMax = underlyingPrice + 5
        let underlyingMin = ((underlyingPrice - underlyingPrice * 0.50) * 100).rounded()/100
        let underlyingMax = ((underlyingPrice + underlyingPrice * 0.50) * 100).rounded()/100
        
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
        
//        underlyingValuesArr = reverseStride(underlyingMax: underlyingMax, underlyingMin: underlyingMin)
//        for i in stride(from: underlyingMin, through: underlyingMax, by: 1){
//            underlyingValuesArr.append(i)
//            print(underlyingValuesArr)
//        }
        //Long Call Implementation
//        for underlying in underlyingValuesArr{
//            if underlying > strikePrice {
//                let diff = underlying - strikePrice
//                tempArr.append(diff)
//                profits.append(-1 * numOfOptions * callPrice + numOfOptions * tempArr.max()!)
//            }else{
//                profits.append(-1 * numOfOptions * callPrice)
//            }
//        }
        //Naked Call Implementation
//        for underlying in underlyingValuesArr{
//            if underlying > strikePrice {
//                let diff = strikePrice - underlying
//                tempArr.append(diff)
//                profits.append(numOfOptions * callPrice + numOfOptions * tempArr.min()!)
//            }else{
//                profits.append(numOfOptions * callPrice)
//            }
//        }
        //Long put implementation
//        for underlying in underlyingValuesArr{
//            if underlying < strikePrice {
//                let diff = strikePrice - underlying
//                tempArr.append(diff)
//                //print(tempArr)
//                profits.append(-1 * numOfOptions * callPrice + numOfOptions * tempArr.max()!)
//            }else{
//                profits.append(-1 * numOfOptions * callPrice)
//            }
//        }
        //Naked put implementation
//        for underlying in underlyingValuesArr{
//            if underlying < strikePrice {
//                let diff = strikePrice - underlying
//                tempArr.append(diff)
//                //print(tempArr)
//                profits.append( numOfOptions * callPrice - numOfOptions * tempArr.max()!)
//            }else{
//                profits.append( numOfOptions * callPrice)
//            }
//        }
//
//        graphProfits = flipArray(flipMe: profits)
//        graphUnderlyingVals = flipArray(flipMe:underlyingValuesArr)

//        print(profits)
//
//        var reversedProfit = [Double]()
//        var reversedUnderlying = [Double]()
//
//        for arrayIndex in stride(from: profits.count - 1, through: 0, by: -1) {
//            reversedProfit.append(profits[arrayIndex])
//        }
//        for arrayIndex in stride(from: underlyingValuesArr.count - 1, through: 0, by: -1) {
//            reversedUnderlying.append(underlyingValuesArr[arrayIndex])
//        }
        
//        for i in 0..<graphProfits.count {
//            print("underlying: \(graphUnderlyingVals[i]) and profit \(graphProfits[i])")
//            let dataEntry = ChartDataEntry(x: graphUnderlyingVals[i], y: graphProfits[i])
//            print(dataEntry)
//            chartDataEntries.append(dataEntry)
//        }
//        let set1 = LineChartDataSet(values: chartDataEntries, label: "Profits")
//        let linechartData = LineChartData(dataSet: set1)
//        lineChartView.data = linechartData
    }

}




