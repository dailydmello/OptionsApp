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
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    //table view should display 10 table view cells. This is hardcoded right now but eventually it'll reflect the number of notes the user has.
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 12
    }
    
    //return a table view cell (UIView subclass) instance. In addition, we configure the default UITableViewCell to display the cell's index path (row and section)
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "listCalcTableViewCell", for: indexPath) as! ListCalcTableViewCell
        cell.strategyTitleLabel.text = "Strategy Title"
        cell.strategyLastModificationStamp.text = "Last Modification Time"
        
        return cell
    
    }
}
