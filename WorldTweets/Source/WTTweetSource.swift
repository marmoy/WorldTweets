//
//  WTTweetSource.swift
//  WorldTweets
//
//  Created by David Marmoy on 16/10/2017.
//  Copyright © 2017 Marmoy. All rights reserved.
//

import Foundation

/**
 The source of the tweets.
 Configures the network connection and the parser
 */
final class WTTweetSource: NSObject, WTStreamSource {
    typealias Value = WTTweet

    private var parser = WTTweetParser()
    private var resultHandler: ((Result<[Value]>) -> Void)?

    lazy var urlSession: URLSession = {
        return URLSession(configuration: .default, delegate: self, delegateQueue: nil)
    }()

    private var entityStreamTask: URLSessionDataTask? {
        willSet {
            parser.resetRemainder()
            entityStreamTask?.cancel()
        }
        didSet {
            entityStreamTask?.resume()
        }
    }

    /**
     Opens the stream.
     - parameter keyword: The keyword by which to filter the stream
     - parameter resultHandler: The function to call when the stream delivers either stream data, or error data
     */
    func openStream(with keyword: String? = nil, resultHandler: ((Result<[Value]>) -> Void)?) {
        WTTwitterStream(keyword: keyword).buildRequest { result in
            guard let request = result.value else {
                resultHandler?(Result.failure(result.error ?? StreamingError.urlRequestCouldNotBeGenerated))
                return
            }

            self.resultHandler = resultHandler
            self.entityStreamTask = self.urlSession.dataTask(with: request)
        }
    }

    /// From URLSessionDataDelegate. Parses the stream and hands over the result to the resultHandler
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        let parsedData = parser.parse(input: data)
        resultHandler?(.success(parsedData))
    }
}
