//
//  WTTweetSource.swift
//  WorldTweets
//
//  Created by David Marmoy on 16/10/2017.
//  Copyright © 2017 Marmoy. All rights reserved.
//

import Foundation

class WTTweetSource: NSObject, WTStreamSource {
    typealias Value = WTTweet

    var parser = WTTweetParser()
    var resultHandler: ((Result<[Value]>) -> Void)?

    lazy var urlSession: URLSession = {
        return URLSession(configuration: .default, delegate: self, delegateQueue: nil)
    }()

    var entityStreamTask: URLSessionDataTask? {
        willSet {
            parser.resetRemainder()
            entityStreamTask?.cancel()
        }
        didSet {
            entityStreamTask?.resume()
        }
    }

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

    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        let parsedData = parser.parse(input: data)
        resultHandler?(.success(parsedData))
    }
}
