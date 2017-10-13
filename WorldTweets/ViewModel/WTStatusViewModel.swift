//
//  WTStatusViewModel.swift
//  WorldTweets
//
//  Created by David Marmoy on 13/10/2017.
//  Copyright © 2017 Marmoy. All rights reserved.
//

import Foundation
import MapKit
import CoreLocation

struct WTStatusViewModel {

    var annotation: MKPointAnnotation

    init?(status: WTStatus) {
        guard let latitude = status.coordinates.latitude, let longitude = status.coordinates.longitude else { return nil }
        let annotation = MKPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        annotation.title = status.text
        self.annotation = annotation
    }
}
