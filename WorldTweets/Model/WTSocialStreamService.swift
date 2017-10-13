//
//  SocialStreamService.swift
//  WorldTweets
//
//  Created by David Marmoy on 10/10/2017.
//  Copyright © 2017 Marmoy. All rights reserved.
//

import Foundation
import Social
import Accounts

protocol WTSocialService {
    var url: URL? { get }
    var parameters: [String: String] { get }
    var serviceType: String { get }
    var accountTypeIdentifier: String { get }
    var requestMethod: SLRequestMethod { get }
}

/// Implements the samples and filter endpoints on the Twitter Streaming API
enum WTTwitterStreamService: WTSocialService {
    case samples
    case filter(track: String?)

    private var baseURL: String { return "https://stream.twitter.com/1.1/" }

    var serviceType: String { return SLServiceTypeTwitter }
    var accountTypeIdentifier: String { return ACAccountTypeIdentifierTwitter }

    var requestMethod: SLRequestMethod {
        switch self {
        case .samples, .filter:
            return .GET
        }
    }

    var url: URL? {
        switch self {
        case .samples:
            return URL(string: baseURL + "statuses/sample.json")
        case .filter:
            return URL(string: baseURL + "statuses/filter.json")
        }
    }

    var parameters: [String: String] {
        switch self {
        case .samples:
            return [:]
        case let .filter(track):
            if let track = track, !track.isEmpty {
                return ["track": track]
            } else {
                // The "@" track  on the filter stream has a massively larger proportion of statuses with locations than the samples stream
                return ["track": "@"]
            }
        }
    }
}
