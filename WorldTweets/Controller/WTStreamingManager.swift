//
//  StreamingManager.swift
//  WorldTweets
//
//  Created by David Marmoy on 11/10/2017.
//  Copyright © 2017 Marmoy. All rights reserved.
//

import Foundation
import Social
import Accounts

protocol WTStatusResponseDelegate: class {
    func statusesReceived(statuses: [WTStatus])
}

/// Orchestrates the social account access, networking and parsing
class WTStreamingManager: NSObject {

    weak var responseDelegate: WTStatusResponseDelegate?

    private var parser: WTStreamingParser
    private var urlSession: URLSession?

    private var statusStreamTask: URLSessionDataTask? {
        willSet {
            parser.resetRemainder()
            statusStreamTask?.cancel()
        }
        didSet {
            statusStreamTask?.resume()
        }
    }

    init(parser: WTStreamingParser) {
        self.parser = parser
        super.init()
        self.urlSession = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
    }
}

// MARK: Social and Accounts dependent
extension WTStreamingManager {
    /**
         Prepares and starts the stream
     
         - parameter streamingService: The social service to stream from
         - parameter errorHandler: Error propagator
     */
     func beginStreaming(from service: WTSocialService, errorHandler: @escaping (StreamingStartupError) -> Void?) {
        let accountStore: ACAccountStore = ACAccountStore()
        let accountType = accountStore.accountType(withAccountTypeIdentifier: service.accountTypeIdentifier)

        accountStore.requestAccessToAccounts(with: accountType, options: nil) { (granted, error) in
            guard granted else {
                errorHandler(StreamingStartupError.accountAccessRejected)
                return
            }

            if error != nil {
                errorHandler(StreamingStartupError.noAccountsExist)
                return
            }

            guard let account = accountStore.accounts(with: accountType).first as? ACAccount else {
                errorHandler(StreamingStartupError.noAccountsExist)
                return
            }

            let streamRequest = SLRequest(
                forServiceType: service.serviceType,
                requestMethod: service.requestMethod,
                url: service.url,
                parameters: service.parameters
            )

            streamRequest?.account = account

            guard let urlRequest = streamRequest?.preparedURLRequest() else {
                errorHandler(StreamingStartupError.urlRequestCouldNotBeGenerated)
                return
            }

            self.statusStreamTask = self.urlSession?.dataTask(with: urlRequest)
        }
    }
}

extension WTStreamingManager: URLSessionDataDelegate {

    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        self.parser.parseData(data: data) { (statuses: [WTStatus]) in
            self.responseDelegate?.statusesReceived(statuses: statuses)
        }
    }
}
