//
//  WTStatusParser.swift
//  WorldTweets
//
//  Created by David Marmoy on 11/10/2017.
//  Copyright © 2017 Marmoy. All rights reserved.
//

import Foundation

protocol WTParser {
    func parseData<T: Decodable>(data: Data, completionHandler: ([T]) -> Void )
}

protocol WTStreamingParser: WTParser {
    var separator: Data { get }
    var remainder: Data { get }
    func resetRemainder()
    init(separator: Data)
}

class WTStatusParser: WTStreamingParser {

    /// The bytes that delimit streaming elements
    var separator: Data

    /// Ensures that any partial trailing statuses are stored and prepended to the next batch of data
    var remainder = Data()

    required init(separator: Data) {
        self.separator = separator
    }

    func resetRemainder() {
        remainder = Data()
    }

    /**
     Parses the stream data, by
     1. Iterating through the raw data
     2. Identifying chunks delimited by the carriage return
     3. Parsing those chunks with JSONDecoder
     
     - parameter data: The data to parse
     - parameter completionHandler: The handler for the parsed objects
     */
    func parseData<T>(data: Data, completionHandler: ([T]) -> Void) where T : Decodable {
        // Get any remaining data from a previous run and concatenate the new data
        var streamData = remainder
        streamData.append(data)

        // If there are no separators in the data, then the whole thing is the new remainder
        guard var nextSeparatorRange = streamData.range(of: separator) else {
            remainder = streamData
            return
        }

        var nextObjectStartIndex = streamData.startIndex

        var parsedObjects = [T]()

        while true {
            let objectRange: Range = nextObjectStartIndex..<nextSeparatorRange.lowerBound

            // Attempt to decode the object
            if let object = try? JSONDecoder().decode(T.self, from: streamData.subdata(in: objectRange)) {
                parsedObjects.append(object)
            }

            nextObjectStartIndex = nextSeparatorRange.upperBound

            // If a separator cannot be found, then we have reached the last object and can break out
            guard let tempRange = streamData.range(of: separator, options: [], in: nextSeparatorRange.upperBound..<streamData.endIndex) else { break }

            // Prepare for next iteration
            nextSeparatorRange = tempRange
        }

        let remainderRange: Range = nextSeparatorRange.upperBound..<streamData.endIndex
        remainder = streamData.subdata(in: remainderRange)

        if parsedObjects.count > 0 {
            completionHandler(parsedObjects)
        }
    }
}
