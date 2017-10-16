//
//  WTTweet.swift
//  WorldTweets
//
//  Created by David Marmoy on 16/10/2017.
//  Copyright © 2017 Marmoy. All rights reserved.
//

import Foundation
import MapKit

protocol WTPinnable {
    var annotation: MKAnnotation? { get }
}

protocol WTLocation: Decodable {
    var coordinates: WTCoordinate { get set }
}

struct WTTweet: WTLocation, CustomStringConvertible {
    private var text: String
    var description: String { return text }
    var coordinates: WTCoordinate
}

struct WTCoordinate: Decodable {
    private var coordinates: [Double]
    var latitude: Double? { return coordinates.last }
    var longitude: Double? { return coordinates.first }
}

extension WTTweet: WTPinnable {
    var annotation: MKAnnotation? {
        guard let latitude = coordinates.latitude, let longitude = coordinates.longitude else { return nil }
        let annotation = MKPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        annotation.title = text
        return annotation
    }
}
