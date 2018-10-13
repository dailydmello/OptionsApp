//
//  ListCalcTableViewController.swift
//  OptionsApp
//
//  Created by Ethan D'Mello on 2018-07-24.
//  Copyright © 2018 Ethan D'Mello. All rights reserved.
//

import Foundation
import UIKit

class ListCalcTableViewController: UITableViewController{
    
    @IBOutlet weak var addBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var aboutBarButtonItem: UIBarButtonItem!
    
    var calculations = [Calculation]() {
        //property observer
        didSet {
            tableView.reloadData()
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        //styling
        setupViews()
        calculations = CoreDataHelper.retrieveCalculation()
    }
    //Asks the data source to return the number of sections in the table view
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return calculations.count
    }
    //Asks the data source for a stylized cell to insert in a particular location of the table view
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "listCalcTableViewCell", for: indexPath) as! ListCalcTableViewCell //typecast to  custom stylized cell
        
        //retrieve the correct calculation based on the index path row and set the calculation cell's labels with the corresponding data
        let calculation = calculations[indexPath.row]
        
        switch calculation.strategy{
        case 0:
            cell.strategyTitleLabel.text = "Long Call"
            let underlyingTicker = calculation.underlyingTicker ?? ""
            let underlyingPrice = calculation.underlyingPrice ?? ""
            cell.underlyingInfoLabel.text = "Underlying: \(underlyingTicker) @ $\(underlyingPrice)"
            let cost = calculation.entryCost ?? ""
            let formCost = formatNumber(numString: cost)
            cell.entryCostInfoLabel.text = "Entry Cost: \(formCost)"
            
        case 1:
            cell.strategyTitleLabel.text = "Naked Call"
            let underlyingTicker = calculation.underlyingTicker ?? ""
            let underlyingPrice = calculation.underlyingPrice ?? ""
            cell.underlyingInfoLabel.text = "Underlying: \(underlyingTicker) @ $\(underlyingPrice)"
            let cost = calculation.entryCost ?? ""
            let formCost = formatNumber(numString: cost)
           cell.entryCostInfoLabel.text = "Entry Premium: \(formCost)"
            
        case 2:
            cell.strategyTitleLabel.text = "Long Put"
            let underlyingTicker = calculation.underlyingTicker ?? ""
            let underlyingPrice = calculation.underlyingPrice ?? ""
            cell.underlyingInfoLabel.text = "Underlying: \(underlyingTicker) @ $\(underlyingPrice)"
            let cost = calculation.entryCost ?? ""
            let formCost = formatNumber(numString: cost)
            cell.entryCostInfoLabel.text = "Entry Cost: \(formCost)"
            
        case 3:
            cell.strategyTitleLabel.text = "Naked Put"
            let underlyingTicker = calculation.underlyingTicker ?? ""
            let underlyingPrice = calculation.underlyingPrice ?? ""
            cell.underlyingInfoLabel.text = "Underlying: \(underlyingTicker) @ $\(underlyingPrice)"
            let cost = calculation.entryCost ?? ""
            let formCost = formatNumber(numString: cost)
            cell.entryCostInfoLabel.text = "Entry Premium: \(formCost)"
            
        default:
            print("unidentified strategy identifier")
        }
        cell.strategyLastModificationStamp.text = calculation.modificationTime?.convertToString() ?? "unknown"
        return cell
    }

    //to delete calculations
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        //retrieve the calculation to be deleted corresponding to the selected index path. Then use Core Data helper to delete the selected calculation. Last, update calculations array to reflect the changes
        if editingStyle == .delete {
            let calculationToDelete = calculations[indexPath.row]
            CoreDataHelper.delete(calculation: calculationToDelete)
            calculations = CoreDataHelper.retrieveCalculation()
        }
    }
    
    //to return to table view screen and pop off calculator view
    @IBAction func unwindWithSegue (_ segue: UIStoryboardSegue){
        //each time the user taps the save or cancel bar button item in CalculationViewController, update calculations array in ListCalcTableViewController
        calculations = CoreDataHelper.retrieveCalculation()
    }
    
    func setupViews(){
        //setting font styles on buttons
        aboutBarButtonItem.setTitleTextAttributes([
            NSAttributedStringKey.font: UIFont(name: "ProximaNova-Light", size: 18.0)!,
            NSAttributedStringKey.foregroundColor: UIColor.tcWhite],
                                                  for: .normal)
        addBarButtonItem.setTitleTextAttributes([
            NSAttributedStringKey.font: UIFont(name: "ProximaNova-Light", size: 18.0)!,
            NSAttributedStringKey.foregroundColor: UIColor.tcWhite],
                                                for: .normal)
        //setting font styles on title
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.font: UIFont(name: "ProximaNova-Semibold", size: 23.0)!,NSAttributedStringKey.foregroundColor: UIColor.tcWhite]
        //setting background of calc notes as black
        self.tableView.backgroundColor = UIColor.tcAlmostBlack
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier else {return}
        switch identifier {
        case "displayCalculation":
            //get a reference path to calculation
            guard let indexPath = tableView.indexPathForSelectedRow else {return}
            //get the calculation at the path
            let calculation = calculations[indexPath.row]
            //get a reference to calculation var in calculator VC
            let destination = segue.destination as! CalculatorViewController
            //set the calculation to selected calculation
            destination.calculation = calculation
            print("save button tapped")
            
        case "addCalculation":
            print("create calculation bar button tapped")
            
        default:
            print("Unexepected segue identifier")
        }
    }
}

