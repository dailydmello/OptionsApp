//
//  CoreDataHelper.swift
//  OptionsApp
//
//  Created by Ethan D'Mello on 2018-07-30.
//  Copyright © 2018 Ethan D'Mello. All rights reserved.
//

import Foundation
import UIKit
import CoreData

struct CoreDataHelper {
    //computed class variable reference to app delegate's managed object context to create, edit, and delete NSManaged Object
    static let context: NSManagedObjectContext = {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            fatalError()
        }
        
        let persistentContainer = appDelegate.persistentContainer
        let context = persistentContainer.viewContext
        
        return context
    }()
   
    static func newCalculation() -> Calculation {
        let calculation = NSEntityDescription.insertNewObject(forEntityName: "Calculation", into: context) as! Calculation
        return calculation
    }
    
    static func saveCalculation(){
        do{
            try context.save()
        } catch let error {
            print("Could not save \(error.localizedDescription)")
        }
    }
    
    static func delete(calculation: Calculation){
        context.delete(calculation)
        saveCalculation()
    }
    
    static func retrieveCalculation() -> [Calculation]{
        do{
            let fetchRequest = NSFetchRequest<Calculation>(entityName: "Calculation")
            let results = try context.fetch(fetchRequest)
            
            return results
        } catch let error {
            print("Could not fetch \(error.localizedDescription)")
            
            return[]
        }
    }
}
