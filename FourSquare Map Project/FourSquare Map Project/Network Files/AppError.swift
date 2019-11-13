//
//  AppError.swift
//  FourSquare Map Project
//
//  Created by Jason Ruan on 11/13/19.
//  Copyright © 2019 Jason Ruan. All rights reserved.
//

import Foundation


enum AppError: Error {
    case unauthenticated
    case invalidJSONResponse
    case couldNotParseJSON(rawError: Error)
    case noInternetConnection
    case badURL
    case badStatusCode
    case noDataReceived
    case notAnImage
    case other(rawError: Error)
}
