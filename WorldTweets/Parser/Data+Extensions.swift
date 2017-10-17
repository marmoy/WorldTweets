//
//  Data+Extensions.swift
//  WorldTweets
//
//  Created by David Marmoy on 16/10/2017.
//  Copyright © 2017 Marmoy. All rights reserved.
//

import Foundation

extension Data: WTSplittable {
    func split(with separator: Data) -> ([Data], Data) {
        guard var nextSeparatorRange = self.range(of: separator) else { return ([], self) }

        var nextObjectStartIndex = self.startIndex

        var splitData = [Data]()

        while true {
            let objectRange: Range = nextObjectStartIndex..<nextSeparatorRange.lowerBound

            splitData.append(self.subdata(in: objectRange))

            nextObjectStartIndex = nextSeparatorRange.upperBound

            // If a separator cannot be found, then we have reached the last object and can break out
            guard let tempRange = self.range(of: separator, options: [], in: nextSeparatorRange.upperBound..<self.endIndex) else { break }

            // Prepare for next iteration
            nextSeparatorRange = tempRange
        }

        let remainderRange: Range = nextSeparatorRange.upperBound..<self.endIndex
        let remainder = self.subdata(in: remainderRange)

        return (splitData, remainder)
    }
}
