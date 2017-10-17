//
//  WTPinnable.swift
//  WorldTweets
//
//  Created by David Marmoy on 17/10/2017.
//  Copyright © 2017 Marmoy. All rights reserved.
//

import Foundation
import MapKit

protocol WTMapPinnable {
    var annotation: MKPointAnnotation? { get }
}
