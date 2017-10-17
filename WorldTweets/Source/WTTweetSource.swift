//
//  WTTweetSource.swift
//  WorldTweets
//
//  Created by David Marmoy on 16/10/2017.
//  Copyright © 2017 Marmoy. All rights reserved.
//

import Foundation

class WTTweetSource: NSObject, WTStreamSource {
    typealias ResultType = WTTweet

    var parser = WTTweetParser()
    var resultHandler: ((Result<[ResultType]>) -> Void)?

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

    func openStream(with keyword: String? = nil, resultHandler: ((Result<[ResultType]>) -> Void)?) {
        WTTwitterStream(keyword: keyword).buildRequest { result in
            guard let request = result.value else {
                resultHandler?(Result.failure(result.error ?? StreamingStartupError.urlRequestCouldNotBeGenerated))
                return
            }

            self.resultHandler = resultHandler
            self.entityStreamTask = self.urlSession.dataTask(with: request)
        }
    }

    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        parser.parse(input: data) { (result) in
            self.resultHandler?(result)
        }
    }
}
