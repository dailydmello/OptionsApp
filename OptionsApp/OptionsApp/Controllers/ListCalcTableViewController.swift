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
    }
    
    //table view should display 10 table view cells. This is hardcoded right now but eventually it'll reflect the number of notes the user has.
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return calculations.count
    }
    
    //return a table view cell (UIView subclass) instance. In addition, we configure the default UITableViewCell to display the cell's index path (row and section)
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "listCalcTableViewCell", for: indexPath) as! ListCalcTableViewCell
        
       //retrieve the correct note based on he index path row and set the note cell's labels with the corresponding data
        let calculation = calculations[indexPath.row]
        cell.strategyTitleLabel.text = calculation.strategyTitle
        cell.strategyLastModificationStamp.text = calculation.modificationTime?.convertToString() ?? "unknown"
        
        return cell
    
    }
    //to delete calculations
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            calculations.remove(at: indexPath.row)
        }
    }
    

    
    @IBAction func unwindWithSegue (_ segue: UIStoryboardSegue){
        
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
            //get a reference to note var in calculator VC
            let destination = segue.destination as! CalculatorViewController
            //set the note to selected note
            destination.calculation = calculation
        
        case "addCalculation":
            print("create calculation bar button tapped")
            
        default:
            print("Unexepected segue identifier")
        }
    }
}

