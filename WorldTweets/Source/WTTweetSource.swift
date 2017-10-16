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
    var resultHandler: (([WTTweet]) -> ())?
    
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
    
    func openStream(with keyword: String? = nil, resultHandler: (([WTTweet]) -> ())?, errorHandler: ((Error) -> ())?) {
        WTTwitterStream(keyword: keyword).buildRequest { (request, error) in
            
            if let error = error {
                errorHandler?(error)
                return
            }
            
            guard let request = request else {
                //errorHandler?(nil) // TODO: create error
                return
            }
            
            self.resultHandler = resultHandler
            self.entityStreamTask = self.urlSession.dataTask(with: request)
        }
    }
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        parser.parse(input: data, completion: resultHandler)
    }
}
