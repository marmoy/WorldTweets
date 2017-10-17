//
//  WTParser.swift
//  WorldTweets
//
//  Created by David Marmoy on 16/10/2017.
//  Copyright © 2017 Marmoy. All rights reserved.
//

import Foundation

protocol WTParser {
    associatedtype InputType
    associatedtype ResultType
    mutating func parse(input: InputType, completion: (([ResultType]) -> Void)?)
}
