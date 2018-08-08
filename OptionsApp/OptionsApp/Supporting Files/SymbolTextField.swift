

//
//  StrikePriceTextField.swift
//  OptionsApp
//
//  Created by Ethan D'Mello on 2018-07-24.
//  Copyright © 2018 Ethan D'Mello. All rights reserved.
//

import Foundation
import UIKit

class SymbolTextField: UITextField {
    
    // MARK: - Properties
    
    var calculateButtonAction: (() -> Void)?
    
    // MARK: - View Lifecycle
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        let toolbar: UIToolbar = UIToolbar()
        
        let leadingFlex = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let trailingFlex = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let calculateButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(calculateButtonTapped(_:)))
        toolbar.items = [leadingFlex, calculateButton, trailingFlex]
        toolbar.tintColor = UIColor.tcWhite
        toolbar.barTintColor = UIColor.tcBlueBlack
        toolbar.isTranslucent = true
        calculateButton.setTitleTextAttributes([
            NSAttributedStringKey.font: UIFont(name: "ProximaNova-Semibold", size: 23.0)!,
            NSAttributedStringKey.foregroundColor: UIColor.tcWhite],
                                          for: .normal)
        
        // resizes toolbar
        toolbar.sizeToFit()
        
        self.inputAccessoryView = toolbar
    }
    
    @objc private func calculateButtonTapped(_ sender: UIBarButtonItem) {
        calculateButtonAction?()
    }
}
