//
//  WTParser.swift
//  WorldTweets
//
//  Created by David Marmoy on 16/10/2017.
//  Copyright © 2017 Marmoy. All rights reserved.
//

import Foundation

protocol WTParser {
    associatedtype Input
    associatedtype Output
    mutating func parse(input: Input) -> [Output]
}
