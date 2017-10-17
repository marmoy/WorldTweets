//
//  WTDataParser.swift
//  WorldTweets
//
//  Created by David Marmoy on 16/10/2017.
//  Copyright © 2017 Marmoy. All rights reserved.
//

import Foundation

protocol WTDataParser: WTParser where InputType == Data, ResultType: Decodable {
    var remainder: InputType { get set }
    var separator: InputType { get set }
    mutating func resetRemainder()
}

extension WTDataParser {
    mutating func parse(input: InputType, completion: (([ResultType]) -> Void)?) {
        var tempData: Data = self.remainder
        tempData.append(input)
        let (elements, remainder) = tempData.split(with: separator )
        self.remainder = remainder
        let decodedElements = elements.flatMap { try? JSONDecoder().decode(ResultType.self, from: $0) }
        completion?(decodedElements)
    }

    mutating func resetRemainder() {
        remainder = InputType()
    }
}
