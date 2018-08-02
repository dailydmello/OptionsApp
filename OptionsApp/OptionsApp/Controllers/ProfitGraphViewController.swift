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

//protocol ProfitGraphViewControllerDelegate{
//    func passDataToCalculator() -> ([Double],String)
//}


class ProfitGraphViewController: UIViewController,ChartViewDelegate{

    //var newData = [Double]()
    var strikePrice: Double = 0
    var underlyingTicker: String = ""
    var underlyingPrice: Double = 0
    var numOfOptions: Double = 0
    var priceOfCall: Double = 0
    var tempArr = [Double]()
    var calculation: Calculation?
    
    @IBOutlet weak var lineChartView: LineChartView!
    
    var delegate: CalculatorViewControllerDelegate?
    var listCalcDelegate: ListCalcTableViewControllerDelegate?
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        if let delegate = delegate {
            //[underlyingPrice,priceOfCall,strikePrice,numOfOptions]
            let newData = delegate.passData()
            print(newData)
            underlyingTicker = newData.1
            underlyingPrice = (100 * Double(newData.0[0])).rounded()/100
            priceOfCall = newData.0[1]
            strikePrice = newData.0[2]
            numOfOptions = newData.0[3]
        }

       updateChartWithData()
        
    }
    
    @IBAction func backButtonTapped(_ sender: Any) {
         self.navigationController?.popViewController(animated: true)
    }
    
    
//    func passDataToCalculator()-> ([Double],String){
//        tempArr.append(self.underlyingPrice)
//        tempArr.append(self.priceOfCall)
//        tempArr.append(self.strikePrice)
//        tempArr.append(self.numOfOptions)
//        return (tempArr,self.underlyingTicker)
//    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier else { return }
        
        switch identifier {
        case "back":
            print("back button tapped")
//            //get a reference path to calculation
//            guard let indexPath = tableView.indexPathForSelectedRow else {return}
//            //get the calculation at the path
//            let calculation = calculations[indexPath.row]
//            //get a reference to calculation var in calculator VC
//            let destination = segue.destination as! CalculatorViewController
//            //set the calculation to selected calculation
//            destination.calculation = calculation
//
//
//            if let calculatorViewController = segue.destination as? CalculatorViewController{
//
//                if let listCalcDelegate = listCalcDelegate{
//                    let calculation = listCalcDelegate.getCalculationObject()
//                    self.calculation = calculation
//                }
//                calculatorViewController.calculation = calculation
          //  }
            
           
//
        default:
            print("unexpected segue identifier")
        }
    }
    
    func updateChartWithData(){
    var chartDataEntries = [ChartDataEntry]()
    var underlyingValuesArr = [Double]()
    var tempArr: [Double] = [0]
    var profits: [Double] = []
    let underlyingMin = ((underlyingPrice - underlyingPrice * 0.10) * 100).rounded()/100
    let underlyingMax = ((underlyingPrice + underlyingPrice * 0.10) * 100).rounded()/100
//    print(underlyingMax)
//    print(underlyingMin)

        for i in stride(from: underlyingMin, through: underlyingMax, by: 0.2){
            underlyingValuesArr.append(i)
        }
        
    // profit = numOfOptions * (Max[0,underlyingPrice - strikePrice] - priceOfCall)
    
    for underlying in underlyingValuesArr{
        if underlying > strikePrice {
        let diff = underlying - strikePrice
        tempArr.append(diff)
            profits.append(-1 * numOfOptions * priceOfCall + numOfOptions * tempArr.max()!)
        }else{
        profits.append(-1 * numOfOptions * priceOfCall)
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




