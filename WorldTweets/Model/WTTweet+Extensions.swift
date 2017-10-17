//
//  WTTweet.swift
//  WorldTweets
//
//  Created by David Marmoy on 16/10/2017.
//  Copyright © 2017 Marmoy. All rights reserved.
//

import Foundation
import MapKit

struct WTTweet: Decodable {
    private var text: String
    var coordinates: WTCoordinate
}

extension WTTweet: CustomStringConvertible {
    var description: String { return text }
}

extension WTTweet: WTMapPinnable {
    var annotation: MKPointAnnotation? {
        guard let latitude = coordinates.latitude, let longitude = coordinates.longitude else { return nil }
        let annotation = MKPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        annotation.title = text
        return annotation
    }
}
