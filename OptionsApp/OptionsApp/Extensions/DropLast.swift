//
//  DopLast.swift
//  OptionsApp
//
//  Created by Ethan D'Mello on 2018-10-12.
//  Copyright © 2018 Ethan D'Mello. All rights reserved.
//

import Foundation

extension String {
    func dropLast(_ n: Int = 1) -> String {
        return String(characters.dropLast(n))
    }
    var dropLast: String {
        return dropLast()
    }
}
