//
//  WTStatusParser.swift
//  WorldTweets
//
//  Created by David Marmoy on 11/10/2017.
//  Copyright © 2017 Marmoy. All rights reserved.
//

import Foundation

class OriginalParser {

    var jsonRemainder = ""

    /**
     This parser converts the data to string and splits it, before converting back to data and then parsing the individual data objects.
     Approximately 11.5 times slower than the new parser
     */
    func parseStreamData<T: Decodable>(streamData: Data, completionHandler: ([T]) -> Void ) {
        guard let responseString = String(data: streamData, encoding: .utf8) else { return }
        var jsonStrings: [Substring] = (jsonRemainder + responseString).split(separator: "\r\n")

        jsonRemainder = String(jsonStrings.popLast() ?? "")

        var parsedObjects = [T]()

        for jsonString in jsonStrings {

            guard let jsonData = jsonString.data(using: .utf8),
                let object = try? JSONDecoder().decode(T.self, from: jsonData)
                else { continue }

            parsedObjects.append(object)
        }

        if parsedObjects.count > 0 {
            completionHandler(parsedObjects)
        }
    }
}
