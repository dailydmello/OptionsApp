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
        }
       updateChartWithData()
    }
    override func viewWillAppear(_ animated: Bool) {
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier else{return}
        switch identifier {
        case "back":
            print("back button tapped")
            self.navigationController?.popViewController(animated: true)
        default:
            print("unexpected segue")
        }
    }
    func updateChartWithData(){
        var chartDataEntries = [ChartDataEntry]()
        var underlyingValuesArr = [Double]()
        var tempArr: [Double] = [0]
        var profits: [Double] = []
        let underlyingMin = ((underlyingPrice - underlyingPrice * 0.10) * 100).rounded()/100
        let underlyingMax = ((underlyingPrice + underlyingPrice * 0.10) * 100).rounded()/100
        for i in stride(from: underlyingMin, through: underlyingMax, by: 0.2){
            underlyingValuesArr.append(i)
        }
        for underlying in underlyingValuesArr{
            if underlying > strikePrice {
                let diff = underlying - strikePrice
                tempArr.append(diff)
                profits.append(-1 * numOfOptions * callPrice + numOfOptions * tempArr.max()!)
            }else{
                profits.append(-1 * numOfOptions * callPrice)
            }
        }
        for i in 0..<underlyingValuesArr.count {
            let dataEntry = ChartDataEntry(x: underlyingValuesArr[i], y: profits[i])
            chartDataEntries.append(dataEntry)
        }
        let set1 = LineChartDataSet(values: chartDataEntries, label: "Profits")
        let linechartData = LineChartData(dataSet: set1)
        lineChartView.data = linechartData
    }
}




