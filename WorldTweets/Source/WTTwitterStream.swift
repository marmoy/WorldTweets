//
//  WTTwitterStream.swift
//  WorldTweets
//
//  Created by David Marmoy on 16/10/2017.
//  Copyright © 2017 Marmoy. All rights reserved.
//

import Foundation
import Social
import Accounts

protocol WTStream {
    var url: URL? { get }
    var parameters: [String: String] { get }
    var serviceType: String { get }
    var accountTypeIdentifier: String { get }
    var requestMethod: SLRequestMethod { get }
    func buildRequest(completionHandler: @escaping (URLRequest?, StreamingStartupError?) -> Void)
}

/// Implements the samples and filter endpoints on the Twitter Streaming API
struct WTTwitterStream: WTStream {
    
    var keyword: String?
    
    init(keyword: String? = nil) {
        self.keyword = keyword
    }
    
    private var baseURL = "https://stream.twitter.com/1.1/"
    
    var serviceType: String { return SLServiceTypeTwitter }
    var accountTypeIdentifier: String { return ACAccountTypeIdentifierTwitter }
    
    var requestMethod: SLRequestMethod { return .GET }
    
    var url: URL? { return URL(string: baseURL + "statuses/filter.json") }
    
    var parameters: [String: String] {
        if let keyword = keyword, !keyword.isEmpty {
            return ["track": keyword]
        } else {
            // The "@" track  on the filter stream has a massively larger proportion of statuses with locations than the samples stream
            return ["track": "@"]
        }
    }
    
    func buildRequest(completionHandler: @escaping (URLRequest?, StreamingStartupError?) -> Void) {
        
        let accountStore: ACAccountStore = ACAccountStore()
        let accountType = accountStore.accountType(withAccountTypeIdentifier: accountTypeIdentifier)
        
        accountStore.requestAccessToAccounts(with: accountType, options: nil) { (granted, error) in
            if error != nil {
                completionHandler(nil, StreamingStartupError.accountError(error as? ACErrorCode))
                return
            }
            
            guard granted else {
                completionHandler(nil, nil)
                return
            }
            
            guard let account = accountStore.accounts(with: accountType).first as? ACAccount else {
                completionHandler(nil, nil)
                return
            }
            
            guard let streamRequest = SLRequest(
                forServiceType: self.serviceType,
                requestMethod: self.requestMethod,
                url: self.url,
                parameters: self.parameters
                ) else {
                    completionHandler(nil, nil)
                    return
            }
            
            streamRequest.account = account
            
            completionHandler(streamRequest.preparedURLRequest(), nil)
        }
    }
}