//
//  NumberFormatter.swift
//  OptionsApp
//
//  Created by Ethan D'Mello on 2018-09-21.
//  Copyright © 2018 Ethan D'Mello. All rights reserved.
//

import Foundation

func formatNumber(numString:String) -> String{
    if let num = Double(numString){
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: num))!
    }else{return "error"}
}
