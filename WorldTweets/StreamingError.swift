//
//  StreamingStartupError.swift
//  WorldTweets
//
//  Created by David Marmoy on 12/10/2017.
//  Copyright © 2017 Marmoy. All rights reserved.
//

import Foundation
import Accounts
import UIKit

enum StreamingError {
    case accountAccessRejected
    case noAccountsExist
    case urlRequestCouldNotBeGenerated
    case propagatedError(Error)
}

extension StreamingError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .accountAccessRejected:
            return NSLocalizedString("accountAccessRejectedDescription", comment: "")
        case .noAccountsExist:
            return NSLocalizedString("noAccountsExistDescription", comment: "")
        case .urlRequestCouldNotBeGenerated:
            return NSLocalizedString("urlRequestCouldNotBeGeneratedDescription", comment: "")
        case let .propagatedError(error):
            return error.localizedDescription
        }
    }

    var recoverySuggestion: String? {
        switch self {
        case .accountAccessRejected:
            return NSLocalizedString("accountAccessRejectedSuggestion", comment: "")
        case .noAccountsExist:
            return NSLocalizedString("noAccountsExistSuggestion", comment: "")
        default:
            return nil
        }
    }
}

protocol RecoverableError: LocalizedError {
    var isRecoverable: Bool { get }
    func recover()
}

extension StreamingError: RecoverableError {
    var isRecoverable: Bool {
        switch self {
        case .accountAccessRejected, .noAccountsExist:
            return true
        default:
            return false
        }
    }

    func recover() {
        switch self {
        case .accountAccessRejected:
            UIApplication.shared.open(URL(string: "App-Prefs:root=Privacy&path=TWITTER")!, options: [:])
        case .noAccountsExist:
            UIApplication.shared.open(URL(string: "App-Prefs:root=TWITTER")!, options: [:])
        default:
            return
        }
    }
}
