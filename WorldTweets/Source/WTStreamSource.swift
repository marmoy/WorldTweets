//
//  WTStreamSource.swift
//  WorldTweets
//
//  Created by David Marmoy on 16/10/2017.
//  Copyright © 2017 Marmoy. All rights reserved.
//

import Foundation

protocol WTStreamSource: URLSessionDataDelegate {
    associatedtype Value
    func openStream(with keyword: String?, resultHandler: ((Result<[Value]>) -> Void)?)
}
