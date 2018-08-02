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
    //we create a computed class variable that gets a reference to our app delegate's managed object context allowing us to create, edit, and delete NSManaged Object
    static let context: NSManagedObjectContext = {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            fatalError()
        }
        
        let persistentContainer = appDelegate.persistentContainer
        let context = persistentContainer.viewContext
        
        return context
    }()
   
    //static method that creates a new  NSManagedObject subclass calculation instance
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
    static func saveUniqueCalculation(calculation: Calculation){
        calculation.uuid = UUID().uuidString
        UserDefaults.standard.set(calculation.uuid, forKey: "uuid")
        
        do{
            try context.save()
        } catch let error {
            print("Could not save \(error.localizedDescription)")
        }
    }
    
    
    
    static func retrieveLastCalculation() -> Calculation?{
        if UserDefaults.standard.value(forKey: "uuid") == nil{
            return nil
        }
        else{
            let uuid =  UserDefaults.standard.value(forKey: "uuid") as! String
            let allCal = retrieveCalculation()
            
            let currentCal = allCal.filter({$0.uuid == uuid})
            return currentCal.first
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
