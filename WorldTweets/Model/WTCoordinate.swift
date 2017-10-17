//
//  WTCoordinate.swift
//  WorldTweets
//
//  Created by David Marmoy on 17/10/2017.
//  Copyright © 2017 Marmoy. All rights reserved.
//

import Foundation

struct WTCoordinate: Decodable {
    private var coordinates: [Double]
    var latitude: Double? { return coordinates.last }
    var longitude: Double? { return coordinates.first }
}
