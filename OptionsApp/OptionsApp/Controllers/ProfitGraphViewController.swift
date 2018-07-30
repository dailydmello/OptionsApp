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
    
    var newData = [Float]()
    var strikePrice: Int = 0
    var underlyingPrice: Int = 0
    var numOfOptions: Int = 0
    var priceOfCall: Int = 0
    
    @IBOutlet weak var lineChartView: LineChartView!
    
    var delegate: CalculatorViewControllerDelegate?
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        if let delegate = delegate {
            //[underlyingPrice,priceOfCall,strikePrice,numOfOptions]
            newData = delegate.passData()
            underlyingPrice = Int(newData[0])
            priceOfCall = Int(newData[1])
            strikePrice = Int(newData[2])
            numOfOptions = Int(newData[3])
        }
        print(newData)
        print(underlyingPrice)
        print(priceOfCall)
        print(strikePrice)
        print(numOfOptions)
       updateChartWithData()
    }
    
    
    func updateChartWithData(){
    var chartDataEntries = [ChartDataEntry]()
    var tempArr: [Int] = [0]
    //var underlyingValues = [Int]()
    var profits: [Int] = []
//    underlyingPrice = 20
//    priceOfCall = 1
//    strikePrice = 20
//    numOfOptions = 1000
    // profit = numOfOptions * (Max[0,underlyingPrice - strikePrice] - priceOfCall)
    //need array of underlying and strikeprice
    let min = underlyingPrice - 5
    let max = underlyingPrice + 5
    let underlyingValues: [Int] = Array(min...max)
    //print(underlyingValues)
    
    for value in underlyingValues{
        if value > strikePrice {
        let diff = value - strikePrice
        tempArr.append(diff)
        profits.append(-1 * numOfOptions * priceOfCall + numOfOptions * tempArr.max()!)
        }else{
        profits.append(-1 * numOfOptions * priceOfCall)
        }
    //print(profits)
        
    //profit = -1 * numOfOptions * priceOfCall + numOfOptions * tempArr.max()!
    //print("The profit is \(profit)")
    //print(tempArr)
    }
    print(underlyingValues)
    print(profits)
    
    for i in 0..<underlyingValues.count {
        let dataEntry = ChartDataEntry(x: Double(underlyingValues[i]), y: Double(profits[i]))
        chartDataEntries.append(dataEntry)
    }
    let set1 = LineChartDataSet(values: chartDataEntries, label: "Profits")
    let linechartData = LineChartData(dataSet: set1)
    lineChartView.data = linechartData
        

    }
}




