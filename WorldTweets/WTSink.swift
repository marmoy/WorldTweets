//
//  WTSink.swift
//  WorldTweets
//
//  Created by David Marmoy on 16/10/2017.
//  Copyright © 2017 Marmoy. All rights reserved.
//

import Foundation

protocol WTSink {
    associatedtype Element: Decodable
    func process(elements: [Element])
}