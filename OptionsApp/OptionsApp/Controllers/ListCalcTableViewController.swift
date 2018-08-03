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
    
    var calculations = [Calculation]() { //property observer
        didSet {
            tableView.reloadData()
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        calculations = CoreDataHelper.retrieveCalculation()
    }
    
    //table view should display 10 table view cells. This is hardcoded right now but eventually it'll reflect the number of calculations the user has.
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return calculations.count
    }
    
    //return a table view cell (UIView subclass) instance. In addition, we configure the default UITableViewCell to display the cell's index path (row and section)
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "listCalcTableViewCell", for: indexPath) as! ListCalcTableViewCell
        
       //retrieve the correct calculation based on he index path row and set the calculation cell's labels with the corresponding data
        let calculation = calculations[indexPath.row]
        switch calculation.strategy{
        case 0:
            cell.strategyTitleLabel.text = "Long Call"
        case 1:
            cell.strategyTitleLabel.text = "Naked Call"
        case 2:
            cell.strategyTitleLabel.text = "Long Put"
        case 3:
            cell.strategyTitleLabel.text = "Naked Put"
        default:
            print("unidentified strategy identifier")
        }
        //cell.strategyTitleLabel.text = String(calculation.strategy)
        cell.strategyLastModificationStamp.text = calculation.modificationTime?.convertToString() ?? "unknown"
        
        return cell
    
    }
    //to delete calculations
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        //retrieve the calculation to be deleted corresponding to the selected index path. Then we use our Core Data helper to delete the selected calculation. Last we update our calculations array to reflect the changes
        
        if editingStyle == .delete {
            let calculationToDelete = calculations[indexPath.row]
            CoreDataHelper.delete(calculation: calculationToDelete)
            
            calculations = CoreDataHelper.retrieveCalculation()
        }
    }
    

    
    @IBAction func unwindWithSegue (_ segue: UIStoryboardSegue){
       //eeach time the user taps the save or cancel bar button item in DisplayCalculationViewController, we update our calculations array in ListCalcTableViewController
        calculations = CoreDataHelper.retrieveCalculation()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier else {return}
        
        switch identifier {
        case "displayCalculation":
            print("claculation cell tapped")
            //get a reference path to calculation
            guard let indexPath = tableView.indexPathForSelectedRow else {return}
            //get the calculation at the path
            let calculation = calculations[indexPath.row]
            //get a reference to calculation var in calculator VC
            let destination = segue.destination as! CalculatorViewController
            //set the calculation to selected calculation
            destination.calculation = calculation
        
        case "addCalculation":
            print("create calculation bar button tapped")
            
        default:
            print("Unexepected segue identifier")
        }
    }
}

