//
//  StreamingStartupError.swift
//  WorldTweets
//
//  Created by David Marmoy on 12/10/2017.
//  Copyright © 2017 Marmoy. All rights reserved.
//

import Foundation

enum StreamingStartupError: Error {
    case accountAccessRejected
    case noAccountsExist
    case urlRequestCouldNotBeGenerated
    case unknownError
}

extension StreamingStartupError: CustomStringConvertible {
    var description: String {
        switch self {
        case .accountAccessRejected:
            return NSLocalizedString("NoTwitterAccountAccessErrorTitle", comment: "")
        case .noAccountsExist:
            return NSLocalizedString("NoTwitterAccountExistsErrorTitle", comment: "")
        default:
            return ""
        }
    }
}
