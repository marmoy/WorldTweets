//
//  WTDataParser.swift
//  WorldTweets
//
//  Created by David Marmoy on 16/10/2017.
//  Copyright © 2017 Marmoy. All rights reserved.
//

import Foundation

protocol WTDataParser: WTParser where Input == Data, Output: Decodable {
    var remainder: Input { get set }
    var separator: Input { get set }
    mutating func resetRemainder()
}

extension WTDataParser {
    /**
     Parses the input data into an array of objects. Uses the remainder across multiple invocations of parse, since the input is unlikely to be cut cleanly between elements
     - parameter input: The data to parse
     - returns: Array of parsed objects
     */
    mutating func parse(input: Input) -> [Output] {
        var tempData: Data = self.remainder
        tempData.append(input)
        let (elements, remainder) = tempData.split(with: separator )
        self.remainder = remainder
        let decodedElements = elements.flatMap { try? JSONDecoder().decode(Output.self, from: $0) }
        return decodedElements
    }

    /**
     Resets the remainder. Call before starting to parse new stream, to avoid getting the new stream data polluted with the remainder from the old stream data
     */
    mutating func resetRemainder() {
        remainder = Input()
    }
}
