//
//  TimeSeriesIntraday.swift
//  OptionsApp
//
//  Created by Ethan D'Mello on 2018-07-25.
//  Copyright © 2018 Ethan D'Mello. All rights reserved.
//

import Foundation

struct TimeSeriesIntraday{
    var _open: String?
    var _high: String?
    var _low: String?
    var _close: String?
    var _volume: String?
    var _timeFrame: Date
    
    var open: String {
        guard let openPrice = _open else {
            print("ERROR in open price")
            return ""
        }
        return openPrice
    }
    
    var high: String {
        guard let highPrice = _high else {
            print("ERROR in high price")
            return ""
        }
        return highPrice
    }
    
    var low: String {
        guard let lowPrice = _low else {
            print("ERROR in low price")
            return ""
        }
        return lowPrice
    }
    
    var close: String {
        guard let closePrice = _open else {
            print("ERROR in close price")
            return ""
        }
        return closePrice
    }
    
    var volume: String {
        guard let volume = _volume else {
            print("ERROR in volume")
            return ""
        }
        return volume
    }
    
    var timeFrame: Date{
        return _timeFrame
    }
    
    init(dict: [String: Any], timeStamp: Date){
        self._open = dict["1. open"] as? String
        self._high = dict["2. high"] as? String
        self._low = dict["3. low"] as? String
        self._close = dict["4. close"] as? String
        self._volume = dict["5. volume"] as? String
        self._timeFrame = timeStamp
    }
    
    static func sortSeriesByTime(array:[TimeSeriesIntraday])->[TimeSeriesIntraday]{
        return array.sorted(by: { $0.timeFrame < $1.timeFrame})
    
    }
    

}
