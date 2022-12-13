//
//  APIError.swift
//  MagicEraser
//
//  Created by Nick Wall on 12/7/22.
//

import Foundation

enum APIError: Error {
    case invalidURL
    case unableToComplete
    case invalidResponse
    case invalidData
}
