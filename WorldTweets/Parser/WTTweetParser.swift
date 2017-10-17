//
//  WTTweetParser.swift
//  WorldTweets
//
//  Created by David Marmoy on 16/10/2017.
//  Copyright © 2017 Marmoy. All rights reserved.
//

import Foundation

struct WTTweetParser: WTDataParser {

    typealias Output = WTTweet
    typealias Input = Data

    var remainder: Data = Data()
    var separator: Data = "\r\n".data(using: .utf8)!
}
