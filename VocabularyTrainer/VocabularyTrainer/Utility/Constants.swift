//
//  Constants.swift
//  VocabularyTrainer
//
//  Created by M, Vijayaragavan (Contractor) on 6/10/18.
//  Copyright © 2018 M, Vijayaragavan. All rights reserved.
//

import Foundation

let errorDomain              = "com.Vocabulary.ErrorDomain"


struct ErrorDescription {
    static let retriveRecordFail      = "Failed to retrieve record"
    static let unableToReadRecord     = "Unable to Read Record from %@"
    
}

enum ErrorType: Int {
    case ErrorRetriveRecordFail = -1989
    case ErrorUnbleReadRecord
}

struct SegueIdentifier {
    static let summaryVC            = "summaryVC"
    static let lessonCompletionVC   = "lessonCompletionVC"
}
